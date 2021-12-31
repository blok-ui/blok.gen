package blok.gen2.routing;

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;

using haxe.macro.Tools;

// @todo: This class is a mess.
class RouteBuilder {
  public static function build() {
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
    var builder = route.parseBuilder();
    var path = route.getMatcher();
    var suffix = haxe.crypto.Md5.encode(path);
    var pack = [ 'blok', 'gen2', 'routing' ];
    var name = 'Route_${suffix}';

    if (!typeExists(pack.concat([ name ]).join('.'))) {
      var params = route.getParams();
      var types:Array<ComplexType> = [ for (entry in params) switch entry.type {
        case 'Int': macro:Int;
        default: macro:String;
      } ];
      var linkProps:Array<Field> = [ for (i in 0...types.length) 
        { name: params[i].key, kind: FVar(types[i]), meta: [], pos: (macro null).pos }
      ];
      var len = params.length;
      var typeParams:Array<TypeParamDecl> = [ { name: 'T' } ];
      var loaderCallParams:Array<Expr> = [ macro context ];
      var pos = Context.currentPos();
      var urlBuilder:Array<Expr> = [ macro $v{builder[0]} ];
      
      for (i in 0...len) {
        var key = params[i].key;
        urlBuilder.push(switch params[i].type {
          case 'String': macro props.$key;
          default: macro Std.string(props.$key);
        });
        if (builder[i + 1] != null) {
          urlBuilder.push(macro $v{builder[i + 1]});
        }
      }

      for (i in 0...len) {
        loaderCallParams.push(macro cast matcher.matched($v{i + 1}));
      }

      var renderFun:ComplexType = TFunction(
        [ macro:blok.context.Context, macro:T ],
        macro:blok.ui.VNode
      );
      var loadFun:ComplexType = TFunction(
        [ macro:blok.context.Context ].concat(types),
        macro:tink.core.Promise<Dynamic>
      );
      var decodeFun:ComplexType = TFunction(
        [ macro:blok.context.Context, macro:Dynamic ],
        macro:T
      );
      var provideFun:ComplexType = TFunction(
        [ macro:blok.context.Context, macro:T ],
        macro:Void
      );

      Context.defineType({
        pack: pack,
        name: name,
        pos: pos,
        params: typeParams,
        kind: TDClass({
          pack: pack,
          name: 'Route',
          sub: 'RouteBase',
          params: [ TPType(TPath({ name: 'T', pack: [] })) ]
        }, [], false, true, false),
        fields: (macro class {
          static final matcher:EReg = new EReg($v{path}, '');

          final render:$renderFun;
          final decoder:$decodeFun;
          final provider:Null<$provideFun>;
          #if blok.platform.static
            final loader:$loadFun;
          #else
            function loader(context:blok.context.Context, url:String) {
              var source = blok.gen2.source.CompiledDataSource.from(context);
              var path = blok.gen2.source.CompiledDataSource.getJsonDataPath(url);
              return switch source.preload(path) {
                case Some(data): tink.core.Promise.resolve(data);
                case None: source.fetch(path);
              }
            }
          #end

          public function new(props:{
            #if blok.platform.static
              load:$loadFun,
            #end
            decode:$decodeFun,
            render:$renderFun,
            ?provide:$provideFun
          }) {
            #if blok.platform.static
              this.loader = props.load;
            #end
            this.provider = props.provide;
            this.decoder = props.decode;
            this.render = props.render;
          }

          public function match(url:String):tink.core.Option<blok.gen2.routing.RouteResult> {
            if (matcher.match(url)) {
              var load = (context:blok.context.Context) -> #if blok.platform.static
                loader($a{loaderCallParams}).next(data -> {
                  var hooks = blok.gen2.core.HookService.from(context);
                  hooks.data.update(DataReady(url, data));
                  return tink.core.Promise.resolve(data);
                });
              #else
                loader(context, url);
              #end
              return Some(createResult(url, load, decoder, provider, render));
            }

            return None;
          }
        }).fields.concat([
          {
            name: 'link',
            access: [ APublic, AStatic ],
            kind: FFun({
              args: [
                { name: 'props', type: TAnonymous(linkProps.concat([
                  ({ 
                    name: 'className', 
                    kind: FVar(macro:String), 
                    meta: [ { name: ':optional', pos: (macro null).pos } ],
                    pos: (macro null).pos
                  }:Field)
                ])) },
                { name: 'children', type: macro:haxe.Rest<blok.ui.VNode> }
              ],
              expr: macro return blok.gen2.ui.PageLink.node({
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
                { name: 'props', type: TAnonymous(linkProps) }
              ],
              ret: macro:String,
              expr: macro return [ $a{urlBuilder} ].join('')
            }),
            pos: (macro null).pos
          }
        ])
      });
    }

    return TPath({
      pack: pack,
      name: name,
      params: [ TPType(ret.toComplexType()) ]
    });
  }

  static function typeExists(name:String) {
    try {
      return Context.getType(name) != null;
    } catch (e:String) {
      return false;
    }
  }
}