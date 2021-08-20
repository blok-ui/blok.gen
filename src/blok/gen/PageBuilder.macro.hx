package blok.gen;

import haxe.macro.Expr;
import haxe.macro.Context;
import blok.tools.ClassBuilder;

using blok.gen.tools.PathTools;

class PageBuilder {
  public static function build() {
    var builder = ClassBuilder.fromContext();
    var clsTp = builder.getTypePath();
    var loader = builder.getField('load');
    var params:Array<Expr> = [];
    var url = builder.cls.name.nameToPath();

    builder.addClassMetaHandler({
      name: 'page',
      hook: Init,
      options: [
        { name: 'route', optional: false }
      ],
      build: function (options: { route:String }, builder, fields) {
        url = options.route;
      }
    });

    builder.addLater(() -> {
      var route:Array<Expr> = url == '/'
        ? [] 
        : url.split('/').map(s -> macro $v{s});

      if (loader == null) {
        Context.error('Requires a `load` method', builder.cls.pos);
      }
  
      switch loader.kind {
        case FFun(f):
          params = [ for (arg in f.args) macro $i{arg.name} ];
          route = route.concat(params);
        default:
          Context.error('`load` must be a function', loader.pos);
      }
      
      var pattern = url == '/'
        ? macro [] | [ '' ]
        : macro [ $a{route} ];
  
      return macro class {
        public static function route():blok.gen.Route<blok.VNode> {
          return new blok.gen.Route(url -> {
            return switch blok.gen.PageTools.prepareUrl(url).split('/') {
              case ${pattern}: 
                Some(blok.gen.data.StoreService.use(service -> {
                  var page = new $clsTp(service.getStore());
                  return blok.gen.PageTools.wrapPage(page, page.load($a{params}));
                }));
              default: 
                None;
            }
          });
        }
      };
    });

    return builder.export();
  }
}
