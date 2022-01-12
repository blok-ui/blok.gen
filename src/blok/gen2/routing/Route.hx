package blok.gen2.routing;

import blok.context.Context;
import blok.context.Provider;
import blok.ui.VNode;
import blok.ui.Effect;
import blok.gen2.core.HookService;
import blok.gen2.core.Config;
import blok.gen2.ui.PageLoader;

using tink.CoreApi;
using blok.gen2.core.Tools;

@:genericBuild(blok.gen2.routing.RouteBuilder.buildGeneric())
class Route<@:const Url, T> {}

abstract class RouteBase<T> implements Matchable {
  function createResult(
    url:String,
    load:(context:Context)->Promise<Dynamic>,
    decode:(context:Context, data:Dynamic)->T,
    render:(context:Context, data:T)->VNode
  ):RouteResult {
    return (context:Context) -> {
      var data = load(context).toObservableResult();
      var config = Config.from(context);
      var hooks = HookService.from(context);

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
            hooks.page.update(PageFailed(url, error));
            Failure(error);
        })
      });
    };
  }
}
