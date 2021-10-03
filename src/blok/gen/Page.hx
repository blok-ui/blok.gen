package blok.gen;

import blok.VNode;

using blok.Effect;

@:autoBuild(blok.gen.PageBuilder.build())
abstract class Page<T> extends Route<PageResult> {
  var context:Null<Context> = null;

  abstract public function decode(data:Dynamic):T;
  abstract public function render(data:T):VNode;
  abstract public function metadata(data:T, meta:MetadataService):Void;

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

  final function createView(url:String, data:Dynamic):VNode {
    var result = decode(data);
    return HookService.use(hooks -> {
      hooks.page.update(PageLoading(url));
      // hooks.onDataReceived.update(data);
      // hooks.onPageLoaded.update(this);
      MetadataService.use(meta -> {
        metadata(result, meta);
        render(result)
          .withEffect(() -> hooks.page.update(PageReady(url, data, this)));
      });
    });
  }
}
