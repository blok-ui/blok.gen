package blok.gen;

using tink.CoreApi;

@:deprecated('Use gen2')
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
    return renderError(e);
  }

  final function createView(url:String, data:Dynamic) {
    return render(decode(data));
  } 
}
