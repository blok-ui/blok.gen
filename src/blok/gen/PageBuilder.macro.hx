package blok.gen;

import haxe.macro.Expr;
import haxe.macro.Context;
import blok.tools.ClassBuilder;

using blok.gen.tools.PathTools;

// @todo: This is a total mess, as we were just trying to make things work.
//        Refactor!
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
      var pattern:Expr = macro [];
      var linkParams:Array<Expr> = [];

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
          pattern = url == '/'
            ? macro [] | [ '' ]
            : macro [ $a{route} ];
          linkParams = [ macro $v{url} ].concat([ for (arg in args) switch arg.type {
            case (macro:String): macro $i{arg.name};
            default: macro Std.string($i{arg.name});
          } ]);

          var expr = f.expr;
          f.expr = macro {
            #if blok.gen.ssr
              ${expr};
            #else
              var __url = haxe.io.Path.join([ $a{[ macro config.siteUrl ].concat(linkParams)} ]);
              return new blok.gen.datasource.HttpDataSource(__url).fetch('data.json');
            #end
          }
        default:
          Context.error('`load` must be a function', loader.pos);
      }

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
                return Some(blok.gen.AppService.use(service -> {
                    var __blokGenPage = new $clsTp(service.config);
                    #if blok.gen.ssr
                      return blok.gen.ssr.SsrService.use(ssr -> {
                        var __promise = __blokGenPage.load($a{params}).next(data -> {
                          ssr.setData(data); // meh
                          data;
                        });
                        return blok.gen.PageTools.wrapPage(__blokGenPage, __promise);
                      });
                    #else
                      blok.gen.PageTools.wrapPage(__blokGenPage, __blokGenPage.load($a{params}));
                    #end
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
