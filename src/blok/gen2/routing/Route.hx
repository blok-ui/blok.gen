package blok.gen2.routing;

import blok.gen2.core.HookService;
import blok.gen2.core.Config;
import blok.gen2.ui.PageLoader;

using tink.CoreApi;
using blok.gen2.core.Tools;

@:genericBuild(blok.gen2.routing.RouteBuilder.build())
class Route<@:const Url, T> {}

abstract class RouteBase<T> extends Matchable {
  function matchChildren(
    url:String,
    load:(context:Context)->Promise<Dynamic>,
    decode:(context:Context, data:Dynamic)->T,
    provider:Null<(context:Context, data:T)->Void>
  ):Option<RouteResult> {
    for (child in children) switch child.match(url) {
      case Some(render) if (provider != null):
        return Some(context -> {
          var data = load(context).toObservableResult();
          var config = Config.from(context);
          return PageLoader.node({
            loading: config.view.loading,
            error: config.view.error,
            result: data.map(result -> switch result {
              case Suspended: Suspended;
              case Failure(error): Failure(error);
              case Success(raw): Success(Provider.provide(
                { register: context -> provider(context, decode(context, raw)) },
                render
              ));
            })
          });
        });
      case Some(render): 
        return Some(render);
      case None:
    }

    return None;
  }

  function createResult(
    url:String,
    load:(context:Context)->Promise<Dynamic>,
    decode:(context:Context, data:Dynamic)->T,
    provider:Null<(context:Context, data:T)->Void>,
    render:(context:Context, data:T)->VNode
  ):RouteResult {
    return (context:Context) -> {
      var data = load(context).toObservableResult();
      var config = Config.from(context);
      var hooks = HookService.from(context);

      if (provider != null) {
        render = (context, data) -> Provider.provide(
          { register: context -> provider(context, data) },
          (context) -> render(context, data)
        );
      }

      return PageLoader.node({
        loading: config.view.loading,
        error: config.view.error,
        result: data.map(result -> switch result {
          case Suspended:
            hooks.page.update(PageLoading(url));
            Suspended;
          case Success(raw):
            var marked = false;
            var data = decode(context, raw);
            Success(Effect.withEffect(
              render(context, data),
              () -> if (!marked) {
                marked = true;
                hooks.page.update(PageReady(url, raw));
              }
            ));
          case Failure(error):
            Failure(error);
        })
      });
    };
  }
}
