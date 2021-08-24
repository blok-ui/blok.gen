package blok.gen.data;

import haxe.macro.Context;
import haxe.macro.Expr;
import blok.tools.ClassBuilder;

using haxe.macro.Tools;
using blok.gen.tools.PathTools;

class ModelBuilder {
  public static function build() {
    var builder = ClassBuilder.fromContext();
    var clsTp = builder.getTypePath();
    var clsType = Context.getLocalType().toComplexType();
    var meta:Null<Expr> = null;

    function buildMetadata(options:{
      name:Null<String>,
      sortBy:Null<Expr>,
      extension:Null<String>,
      idProperty:Null<String>
    }) {
      var name = options.name == null
        ? builder.cls.name.nameToPath()
        : options.name;
      var ext = options.extension == null
        ? 'md'
        : options.extension;
      var id = options.idProperty == null
        ? 'id'
        : options.idProperty;
      return macro ({
        name: $v{name},
        extension: $v{ext},
        idProperty: $v{id},
        create: (props) -> if (props != null) new $clsTp(props) else null,
        #if blok.gen.ssr
          parse: parse
        #end
      }:blok.gen.data.ModelMetadata<$clsType>); 
    }

    builder.addClassMetaHandler({
      name: 'model',
      hook: Init,
      options: [
        { name: 'name', optional: true },
        { name: 'sortBy', optional: true, handleValue: e -> e  },
        { name: 'extension', optional: true },
        { name: 'idProperty', optional: true }
      ],
      build: function (options:{
        name:Null<String>,
        sortBy:Null<Expr>,
        extension:Null<String>,
        idProperty:Null<String>
      }, builder, fields) {
        meta = buildMetadata(options);
      }
    });

    builder.addLater(() -> {
      if (meta == null) {
        meta = buildMetadata({
          name: null,
          sortBy: null,
          extension: null,
          idProperty: null
        });
      }

      if (Context.defined('blok.gen.ssr')) {
        var parse = builder.getField('parse');
        if (
          parse == null || !parse.access.contains(AStatic)
        ) {
          Context.error('A static `parse` field is required for all models', builder.cls.pos);
        }
        switch parse.kind {
          case FFun(f):
            // todo
          default:
            Context.error('Must be a function', parse.pos);
        }
      }

      return macro class {
        static final __meta:blok.gen.data.ModelMetadata<$clsType> = ${meta};
        
        public static function fromStore(store:blok.gen.data.Store) {
          return new blok.gen.data.QueryBuilder(__meta, store);
        }
      }
    });

    return builder.export();
  }
}
