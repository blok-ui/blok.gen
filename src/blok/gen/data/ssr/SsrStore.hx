package blok.gen.data.ssr;

import haxe.ds.HashMap;
import haxe.Json;
import blok.gen.storage.Writer;
import blok.gen.storage.Reader;
import blok.gen.storage.FileResult;
import blok.gen.ssr.FormatterCollection;
import blok.gen.data.QueryBuilder.SortBy;
import blok.gen.data.QueryBuilder.QueryModifier;

using Lambda;
using Reflect;
using tink.CoreApi;
using haxe.io.Path;

class SsrStore implements Store {
  final reader:Reader;
  final writer:Writer;
  final formatters:FormatterCollection;
  final cache:HashMap<QueryBuilder<Dynamic>, StoreResult<Dynamic>> = new HashMap();

  public function new(reader, writer, formatters) {
    this.reader = reader;
    this.writer = writer;
    this.formatters = formatters;
  }
  
  public function find<T:Model>(query:QueryBuilder<T>):Promise<StoreResult<T>> {
    if (cache.exists(query)) return Promise.resolve(cast cache.get(query));
    
    return (switch query.type {
      case QueryNone: 
        Promise.resolve(({
          meta: {
            startIndex: 0,
            endIndex: 0,
            count: 0,
            total: 0
          },
          data: []
        }:StoreResult<T>));
      case QueryAll(modifiers):
        findAll(modifiers, query.meta);
      case QueryRange(first, count, modifiers):
        findMany(first, count, modifiers, query.meta);
      case QueryById(id, modifiers):
        findOne(id, modifiers, query.meta);
    }).next(result -> {
      saveJson(query, result);
      var models:StoreResult<T> = {
        meta: result.meta,
        data: result.data.map(query.meta.create)
      };
      cache.set(query, models);
      return models;
    });
  }

  function findOne<T:Model>(id:String, modifiers:Array<QueryModifier>, meta):Promise<StoreResult<Dynamic>> {
    var ext = modifiers.find(m -> m.match(QueryExtension(_))).getValue();
    var child = modifiers.find(m -> m.match(QueryChild(_))).getValue();
    var includeSiblings = modifiers.exists(m -> m.match(QueryWithSiblings));

    return baseFind(meta, child, ext)
      .next(results -> Promise.inParallel(results.map(res -> format(meta, res))))
      .next(results -> {
        var file = results.find((data:Dynamic) -> data.field(meta.idProperty) == id);
        if (file == null) {
          return new Error(404, 'No model exists with the id ${id}');
        }
        return Promise.resolve(if (includeSiblings) {
          var index = results.indexOf(file);
          var prev = results[index - 1];
          var next = results[index + 1];
          var data = [ prev, file, next ];
          var real = data.filter(d -> d != null);
          return {
            meta: {
              startIndex: results.indexOf(real[0]),
              endIndex: results.indexOf(real[real.length - 1]),
              total: results.length,
              count: real.length
            },
            data: data
          };
        } else {
          return {
            meta: {
              startIndex: results.indexOf(file),
              endIndex: results.indexOf(file),
              total: results.length,
              count: 1
            },
            data: [ file ]
          };
        });
      });
  }

  function findMany<T:Model>(first:Int, count:Int, modifiers:Array<QueryModifier>, meta):Promise<StoreResult<Dynamic>> {
    var sort = modifiers.find(m -> m.match(QuerySort(_))).getValue();
    var ext = modifiers.find(m -> m.match(QueryExtension(_))).getValue();
    var child = modifiers.find(m -> m.match(QueryChild(_))).getValue();
    
    return baseFind(meta, sort, child, ext)
      .next(files -> {
        if (files.length < first) {
          return new Error(404, 'The requested start index is out of range');
        }
        var data = files.slice(first, first + count);
        if (data.length <= 0) {
          trace(first + ' ' + count);
          return new Error(404, 'No data found');
        }
        return {
          meta: {
            startIndex: files.indexOf(data[0]),
            endIndex: files.indexOf(data[data.length - 1]),
            count: data.length,
            total: files.length
          },
          data: data
        };
      })
      .next(result -> {
        Promise
          .inParallel(result.data.map(res -> format(meta, res)))
          .next(data -> {
            meta: result.meta,
            data: data
          });
      });
  }

  function findAll(modifiers:Array<QueryModifier>, meta):Promise<StoreResult<Dynamic>> {
    var sort = modifiers.find(m -> m.match(QuerySort(_))).getValue();
    var ext = modifiers.find(m -> m.match(QueryExtension(_))).getValue();
    var child = modifiers.find(m -> m.match(QueryChild(_))).getValue();
    
    return baseFind(meta, sort, child, ext)
      .next(files -> {
        return {
          meta: {
            startIndex: 0,
            endIndex: files.indexOf(files[files.length - 1]),
            count: files.length,
            total: files.length
          },
          data: files
        }
      })
      .next(result -> {
        Promise
          .inParallel(result.data.map(res -> format(meta, res)))
          .next(data -> {
            meta: result.meta,
            data: data
          });
      });
  }

  function baseFind<T:Model>(meta:ModelMetadata<T>, ?sort:SortBy, ?child:String, ?ext:String) {
    var extension = ext == null
      ? meta.extension
      : ext;
    if (sort == null) sort = SortCreated;
    // todo: figure out child
    return reader
      .list(meta.name, name -> name.extension() == extension)
      .next(files -> switch sort {
        case SortCreated:
          files.sort((a, b) -> Math.ceil(a.meta.created.getTime() - b.meta.created.getTime()));
          files;
        case SortUpdated:
          files.sort((a, b) -> Math.ceil(a.meta.updated.getTime() - b.meta.updated.getTime()));
          files;
        case SortName:
          files;
      });
  }

  function saveJson<T:Model>(query:QueryBuilder<T>, json:StoreResult<Dynamic>) {
    writer.write(query.getJsonName(), Json.stringify(json));
  }

  function format<T:Model>(meta:ModelMetadata<T>, result:FileResult):Promise<{}> {
    var formatter = formatters.find(result.meta.extension);
    if (formatter == null) return new Error(404, 'No formatter found');
    return formatter
      .parse(result)
      .next(data -> try {
        meta.parse(result, data);
      } catch (e) {
        new Error(500, e.message);
      });
  }
}