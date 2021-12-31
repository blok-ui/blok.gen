package blok.gen;

import haxe.macro.Expr;
import haxe.macro.Context;
import blok.macro.ClassBuilder;

using blok.gen.PathTools;
using haxe.macro.Tools;

class PageRouteBuilder {
  public static function build() {
    var builder = ClassBuilder.fromContext();
    var clsTp = builder.getTypePath();
    var url = builder.cls.name.nameToPath();
    
    if (builder.getField('match') != null) {
      Context.error('`match` cannot be manually generated on pages', builder.getField('match').pos);
    }

    if (builder.cls.superClass.t.get().module != 'blok.gen.PageRoute') {
      Context.error('Pages must extend blok.gen.PageRoute', builder.cls.pos);
    }

    var dataType = builder.cls.superClass.params[0].toComplexType();

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
      var args:Array<FunctionArg> = [];
      var fromParams:Array<Expr> = [];
      var toParams:Array<Expr> = [];
      var pattern:Expr = macro [];
      var loader = builder.getField('load');

      if (loader == null) {
        Context.error('Requires a `load` method', builder.cls.pos);
      }
      if (!loader.access.contains(APublic)) {
        Context.error('`load` cannot be private', loader.pos);
      }
      if (loader.access.contains(AStatic)) {
        Context.error('`load` cannot be static', loader.pos);
      }

      switch loader.kind {
        case FFun(f):
          if (f.ret != null && Context.unify(f.ret.toType(), Context.getType('blok.state.ObservableResult'))) {
            Context.error('`load` must return a blok.state.ObservableResult', loader.pos);
          } else if (f.ret == null) {
            f.ret = macro:blok.state.ObservableResult<Dynamic, tink.core.Error>;
          }

          args = f.args;
          fromParams = [ for (arg in args) switch arg.type {
            case (macro:String): 
              macro $i{arg.name};
            case (macro:Int):
              macro Std.parseInt($i{arg.name});
            default:
              Context.error('Invalid param type', loader.pos);
              null; 
          }];
          toParams = [ macro $v{url} ].concat([ for (arg in args) switch arg.type {
            case (macro:String): macro $i{arg.name};
            default: macro Std.string($i{arg.name});
          } ]);
          route = route.concat([ for (arg in args) macro $i{arg.name} ]);
          pattern = url == '/'
            ? macro [] | [ '' ]
            : macro [ $a{route} ];
            
          var expr = f.expr;
          f.expr = macro {
            #if blok.platform.static
              return $expr;
            #else
              return switch findParentOfType(blok.gen.RouteContext) {
                case Some(context):
                  var source = context.getService(blok.gen.datasource.CompiledDataSource);
                  var path = haxe.io.Path.join([ $a{toParams.concat([ macro 'data.json' ])} ]);
                  return switch source.preload(path) {
                    case Some(data): blok.state.ObservableResult.ofResult(Success(data));
                    case None: source.fetch(path);
                  }
                case None: 
                  blok.state.ObservableResult.ofResult(Failure(new tink.core.Error(500, 'RouteContext not available')));
              }
            #end
          }

        default:
          Context.error('`load` must be a function', loader.pos);
      }
      
      var props:Array<Field> = [
        { 
          name: 'className', 
          kind: FVar(macro:String), 
          meta: [ { name: ':optional', pos: (macro null).pos } ],
          pos: (macro null).pos
        }
      ];
      var linkBody:Array<Expr> = [];
      for (arg in args) {
        var name = arg.name;
        props.push({
          name: name,
          kind: FVar(arg.type),
          meta: arg.opt == true
            ? [ { name: ':optional', pos: (macro null).pos } ]
            : [],
          pos: (macro null).pos
        });
        linkBody.push(macro var $name = props.$name);
      }
      
      var linkProps = TAnonymous(props);

      linkBody.push(macro return blok.gen.PageLink.node({
        className: props.className,
        url: haxe.io.Path.join([ $a{toParams} ]),
        children: children.toArray()
      }));

      builder.addFields([
        {
          name: 'link',
          access: [ APublic, AStatic ],
          kind: FFun({
            args: [
              { name: 'props', type: macro:$linkProps },
              { name: 'children', type: macro:haxe.Rest<blok.ui.VNode> }
            ],
            expr: macro $b{linkBody}
          }),
          pos: (macro null).pos
        }
      ]);
      
      builder.addFields([
        {
          name: 'getUrl',
          access: [ APublic, AStatic ],
          kind: FFun({
            args: args,
            expr: macro return haxe.io.Path.join([ $a{toParams} ])
          }),
          pos: (macro null).pos
        }
      ]);

      return macro class {
        override public function match(url:String):haxe.ds.Option<blok.state.ObservableResult<blok.ui.VNode, tink.core.Error>> {
          return switch blok.gen.PathTools.prepareUrl(url).split('/') {
            case ${pattern}:
              var hooks = getContext().getService(blok.gen.HookService);
              return Some(load($a{fromParams}).map(result -> switch result {
                case Suspended:
                  hooks.page.update(PageLoading(url));
                  Suspended;
                case Success(data):
                  var marked = false;
                  var view = blok.ui.Effect.withEffect(
                    createView(url, data),
                    () -> if (!marked) {
                      marked = true;
                      hooks.page.update(PageReady(url, data, this));
                    }
                  );
                  Success(view);
                case Failure(error): 
                  var view = blok.ui.Effect.withEffect(
                    createErrorView(url, error),
                    () -> hooks.page.update(PageFailed(url, error, this))
                  );
                  Success(view);
              }));
            default:
              super.match(url);
          }
        }
      };
    });

    return builder.export();
  }
}
