package blok.gen;

using tink.CoreApi;
using blok.Effect;

@:autoBuild(blok.gen.PageRouteBuilder.build())
abstract class PageRoute<T> extends Route<PageResult> {
  var context:Null<Context> = null;

  abstract public function decode(data:Dynamic):T;
  abstract public function render(data:T):VNode;

  public function renderError(e:Error):VNode {
    return Config.use(config -> config.view.error(e));
  }

  public inline function getService<T:ServiceProvider>(resolver:ServiceResolver<T>):T {
    return getContext().getService(resolver);
  }

  public function getContext():Context {
    return switch findParentOfType(RouteContext) {
      case Some(routeContext): 
        context = routeContext.getContext();
      case None:
        throw 'Could not find route context';
    }
  }

  final function createErrorView(url:String, e:Error) {
    return HookService.use(hooks -> {
      renderError(e)
        .withEffect(() -> hooks.page.update(PageFailed(url, e, this)));
    });
  }

  final function createView(url:String, data:Dynamic) {
    return HookService.use(hooks -> {
      render(decode(data))
        .withEffect(() -> hooks.page.update(PageReady(url, data, this)));
    });
  } 
}
