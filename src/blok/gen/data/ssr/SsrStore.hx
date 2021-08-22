package blok.gen.data.ssr;

import haxe.ds.HashMap;
import haxe.Json;
import blok.gen.storage.Writer;
import blok.gen.storage.Reader;
import blok.gen.storage.FileResult;
import blok.gen.ssr.FormatterCollection;

using Lambda;
using Reflect;
using tink.CoreApi;
using haxe.io.Path;

class SsrStore implements Store {
  final reader:Reader;
  final writer:Writer;
  final formatters:FormatterCollection;
  final cache:HashMap<Query<Dynamic>, StoreResult<Dynamic>> = new HashMap();

  public function new(reader, writer, formatters) {
    this.reader = reader;
    this.writer = writer;
    this.formatters = formatters;
  }
  
  public function find<T:Model>(query:Query<T>):Promise<StoreResult<T>> {
    if (cache.exists(query)) return Promise.resolve(cast cache.get(query));
    return (switch query.id {
      case null:
        findMany(query);
      case id:
        findOne(id, query);
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

  function findOne<T:Model>(id:String, query:Query<T>):Promise<StoreResult<Dynamic>> {
    return baseFind(query.meta)
      .next(results -> Promise.inParallel(results.map(res -> format(query, res))))
      .next(results -> {
        var file = results.find((data:Dynamic) -> data.field(query.meta.idProperty) == id);
        if (file == null) {
          return new Error(404, 'No model exists with the id ${id}');
        }
        return Promise.resolve(if (query.includeSiblings) {
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

  function findMany<T:Model>(query:Query<T>):Promise<StoreResult<Dynamic>> {
    return baseFind(query.meta)
      .next(files -> {
        if (files.length < query.first) {
          return new Error(404, 'The requested start index is out of range');
        }
        var data = files.slice(query.first, query.first + query.count);
        if (data.length <= 0) {
          trace(query.first + ' ' + query.count);
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
          .inParallel(result.data.map(res -> format(query, res)))
          .next(data -> {
            meta: result.meta,
            data: data
          });
      });
  }

  function baseFind<T:Model>(meta:ModelMetadata<T>) {
    return reader
      .list(meta.name, name -> name.extension() == meta.extension)
      .next(files -> switch meta.sortBy {
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

  function saveJson<T:Model>(query:Query<T>, json:StoreResult<Dynamic>) {
    writer.write(query.asJsonName(), Json.stringify(json));
  }

  function format<T:Model>(query:Query<T>, result:FileResult):Promise<{}> {
    var formatter = formatters.find(result.meta.extension);
    if (formatter == null) return new Error(404, 'No formatter found');
    return formatter
      .parse(result)
      .next(data -> try {
        query.meta.parse(result, data);
      } catch (e) {
        new Error(500, e.message);
      });
  }
}