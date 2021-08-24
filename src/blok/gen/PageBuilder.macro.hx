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

      var args:Array<FunctionArg> = [];
  
      switch loader.kind {
        case FFun(f):
          args = f.args;
          params = [ for (arg in f.args) switch arg.type {
            case (macro:String): 
              macro $i{arg.name};
            case (macro:Int):
              macro Std.parseInt($i{arg.name});
            default:
              Context.error('Invalid param type', loader.pos);
              null; 
          }];
          route = route.concat([ for (arg in f.args) macro $i{arg.name} ]);
        default:
          Context.error('`load` must be a function', loader.pos);
      }
      
      var pattern = url == '/'
        ? macro [] | [ '' ]
        : macro [ $a{route} ];

      var linkParams = [ macro $v{url} ].concat([ for (arg in args) switch arg.type {
        case (macro:String): macro $i{arg.name};
        default: macro Std.string($i{arg.name});
      } ]);

      builder.addFields([
        {
          name: 'link',
          access: [ APublic, AStatic ],
          kind: FFun({
            args: args.concat([ { name: 'child', type: macro:blok.VNode } ]),
            expr: macro return blok.gen.PageLink.node({
              url: haxe.io.Path.join([ $a{linkParams} ]),
              child: child
            })
          }),
          pos: (macro null).pos
        }
      ]);
  
      return macro class {
        public static function route():blok.gen.Route<blok.VNode> {
          return new blok.gen.Route(url -> {
            return switch blok.gen.PageTools.prepareUrl(url).split('/') {
              case ${pattern}: 
                Some(blok.gen.data.StoreService.use(service -> {
                  var __blokGenPage = new $clsTp(service.getStore());
                  return blok.gen.PageTools.wrapPage(__blokGenPage, __blokGenPage.load($a{params}));
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
