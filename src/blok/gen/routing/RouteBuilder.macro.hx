package blok.gen.routing;

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;
import blok.macro.ClassBuilder;

using haxe.macro.Tools;
using blok.gen.macro.Tools;

class RouteBuilder {
  public static function buildGeneric() {
    return switch Context.getLocalType() {
      case TInst(_, [
        TInst(_.get() => {kind: KExpr(macro $v{(url:String)})}, _), 
        ret 
      ]):
        buildRoute(url, ret);
      default:
        throw 'assert';
    }
  }

  static function buildRoute(url:String, ret:Type):ComplexType {
    var route = new RouteParser(url);
    var pos = Context.currentPos();
    var path = route.getMatcher();
    var params = route.getParams();
    var builder = route.getParts();
    var suffix = haxe.crypto.Md5.encode(path);
    var pack = [ 'blok', 'gen', 'routing' ];
    var name = 'Route_${suffix}';

    if (!pack.concat([ name ]).join('.').typeExists()) {
      var routeFields:Array<Field> = [ for (entry in params) switch entry.type {
        case 'Int': { name: entry.key, kind: FVar(macro:Int), pos: pos };
        default: { name: entry.key, kind: FVar(macro:String), pos: pos };
      } ];
      var routeParams:ComplexType = TAnonymous(routeFields);
      var loaderCallParams:Expr = {
        expr: EObjectDecl([ for (i in 0...routeFields.length) {
          field: routeFields[i].name,
          expr: macro cast matcher.matched($v{i + 1})
        }  ]),
        pos: pos
      };
      var pos = Context.currentPos();
      var urlBuilder:Array<Expr> = [ macro $v{builder[0]} ];

      for (i in 0...params.length) {
        var key = params[i].key;
        urlBuilder.push(switch params[i].type {
          case 'String': macro props.$key;
          default: macro Std.string(props.$key);
        });
        if (builder[i + 1] != null) {
          urlBuilder.push(macro $v{builder[i + 1]});
        }
      }

      Context.defineType({
        pack: pack,
        name: name,
        pos: pos,
        params: [ { name: 'T' } ],
        kind: TDClass({
          pack: pack,
          name: 'Route',
          sub: 'RouteBase',
          params: [ TPType(TPath({ name: 'T', pack: [] })) ]
        }, [], false, false, true),
        fields: (macro class {
          static final matcher:EReg = new EReg($v{path}, '');
          
          #if blok.platform.static
            abstract function load(context:blok.context.Context, props:$routeParams):tink.core.Promise<Dynamic>;
          #else
            final function load(context:blok.context.Context, url:String) {
              var source = blok.gen.source.CompiledDataSource.from(context);
              var path = blok.gen.source.CompiledDataSource.getJsonDataPath(url);
              return switch source.preload(path) {
                case Some(data): tink.core.Promise.resolve(data);
                case None: source.fetch(path);
              }
            }
          #end

          public function new() {}

          abstract function decode(context:blok.context.Context, data:Dynamic):T;

          abstract function render(context:blok.context.Context, data:T):blok.ui.VNode;

          public function match(url:String):tink.core.Option<blok.gen.routing.RouteResult> {
            if (matcher.match(url)) {
              #if blok.platform.static
                var params = ${loaderCallParams};
                var wrappedLoader = (context:blok.context.Context) -> load(context, params).next(data -> {
                  var hooks = blok.gen.core.HookService.from(context);
                  hooks.data.update(DataReady(url, data));
                  return tink.core.Promise.resolve(data);
                });
              #else
                var wrappedLoader = (context:blok.context.Context) -> load(context, url);
              #end
              return Some(createResult(url, wrappedLoader, decode, render));
            }

            return None;
          }
        }).fields.concat([
          {
            name: 'link',
            access: [ APublic, AStatic ],
            kind: FFun({
              args: [
                { name: 'props', type: TAnonymous(routeFields.concat([
                  ({ 
                    name: 'className', 
                    kind: FVar(macro:String), 
                    meta: [ { name: ':optional', pos: (macro null).pos } ],
                    pos: (macro null).pos
                  }:Field)
                ])) },
                { name: 'children', type: macro:haxe.Rest<blok.ui.VNode> }
              ],
              expr: macro return blok.gen.ui.PageLink.node({
                className: props.className,
                url: toUrl(props),
                children: children.toArray()
              })
            }),
            pos: (macro null).pos
          },

          {
            name: 'toUrl',
            access: [ APublic, AStatic ],
            kind: FFun({
              args: [
                { name: 'props', type: routeParams }
              ],
              ret: macro:String,
              expr: macro return [ $a{urlBuilder} ].join('')
            }),
            pos: (macro null).pos
          }
        ]),
        meta: [
          {
            name: ':autoBuild',
            params: [ macro blok.gen.routing.RouteBuilder.build() ],
            pos: pos
          }
        ]
      });
    }

    return TPath({
      pack: pack,
      name: name,
      params: [ TPType(ret.toComplexType())  ]
    });
  }

  public static function build() {
    var builder = ClassBuilder.fromContext();

    if (Context.defined('blok.platform.dom') && builder.fieldExists('load')) {
      // @todo: better warning
      Context.warning(
        'Make sure you wrap your load method with `#if blok.platform.static`. '
        + 'In all other contexts, Blok will generate a load method and you will '
        + 'encounter a compiler error.',
        builder.getField('load').pos
      );
    }

    var superClass = builder.cls.superClass.t.get();
    var scPath = superClass.pack.concat([ superClass.name ]);
    
    // note: At the moment, all this really does is forward the `link` and `toUrl`
    //       methods to the final class.
    builder.add(macro class {
      public static inline function link(props, ...children:blok.ui.VNode) {
        return $p{scPath}.link(props, ...children);
      }

      public static inline function toUrl(props) {
        return $p{scPath}.toUrl(props);
      }
    });

    return builder.export();
  }
}