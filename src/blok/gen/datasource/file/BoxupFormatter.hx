package blok.gen.datasource.file;

import boxup.Source;
import boxup.Node;
import boxup.Parser;
import boxup.Scanner;
import boxup.schema.Schema;
import boxup.schema.SchemaId;
import boxup.schema.SchemaCompiler;
import boxup.schema.SchemaCollection;
import blok.gen.datasource.FileDataSource;
import blok.gen.datasource.FileResult;

using haxe.io.Path;
using tink.CoreApi;
using boxup.schema.SchemaTools;

class BoxupFormatter<T> implements Formatter<T> {
  final config:BoxupFormatterConfig<T>;
  final schemaSource:FileDataSource;
  final schemaCollection:SchemaCollection = new SchemaCollection();

  public function new(config, schemaSource) {
    this.config = config;
    this.schemaSource = schemaSource;
  }

  public function parse(file:FileResult):Promise<T> {
    return new Promise((res, rej) -> {
      var source:Source = {
        content: file.content,
        file: file.meta.path
      };

      Scanner
        .scan(source)
        .map(Parser.parse)
        .handleValue(nodes -> {
          nodes
            .findSchema()
            .handleValue(id -> {
              maybeLoadSchema(id).handle(o -> switch o {
                case Success(schema): 
                  compile(schema, nodes)
                    .handleValue(res)
                    .handleError(e -> {
                      config.reporter.report(e, source);
                      rej(new Error(500, 'Could not compile boxup: ' + e.message));
                    });
                case Failure(e):
                  rej(e);
              });
            })
            .handleError(e -> rej(new Error(500, e.message)));
        })
        .handleError(e -> {
          config.reporter.report(e, source);
          rej(new Error(500, 'Could not compile boxup: ' + e.message));
        });

      () -> null;
    });
  }

  function compile(schema:Schema, nodes:Array<Node>) {
    var generator = config.generatorFactory(schema);
    return schema
      .validate(nodes)
      .map(generator.generate);
  }

  function maybeLoadSchema(id:SchemaId):Promise<Schema> {
    var schema = schemaCollection.get(id);
    if (schema != null) return Promise.resolve(schema);
    return schemaSource.get(
      Path.join([ config.schemaPath, id.toString() ]).withExtension('box')
    ).next(file -> {
      var compiler = new SchemaCompiler(config.reporter);
      return new Promise((res, rej) -> {
        compiler.compile({
          content: file.content,
          file: file.meta.path
        }).handleValue(schema -> {
          schemaCollection.add(schema);
          res(schema);
        }).handleError(e -> rej(new Error(500, e.message)));
        () -> null;
      });
    });
  }
}
