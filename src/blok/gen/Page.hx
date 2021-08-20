package blok.gen;

import blok.VNode;
import blok.gen.data.Store;
import blok.core.foundation.suspend.Suspend;
import blok.gen.async.SuspendablePromise;

using tink.CoreApi;

@:autoBuild(blok.gen.PageBuilder.build())
abstract class Page<T> implements Route<VNode> {
  final store:Store;

  public function new(store) {
    this.store = store;
  }

  abstract public function match(url:String):Option<RouteAction<VNode>>;
  
  abstract public function render(meta:MetadataService, data:T):VNode;

  function renderLoading():VNodeResult {
    return AppService.use(app -> app.loadingPage());
  }

  inline function wrap(suspendable:SuspendablePromise<T>) {
    return Suspend.await(
      () -> {
        var data = suspendable.get();
        return MetadataService.use(meta -> render(meta, data));
      },
      renderLoading
    );
  }
}
