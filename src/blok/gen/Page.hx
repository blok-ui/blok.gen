package blok.gen;

import blok.VNode;
import blok.gen.data.Store;

using tink.CoreApi;

@:autoBuild(blok.gen.PageBuilder.build())
abstract class Page<T> {
  final store:Store;

  final public function new(store) {
    this.store = store;
  }

  abstract public function render(meta:MetadataService, data:T):VNode;

  public function renderLoading():VNodeResult {
    return AppService.use(app -> app.loadingPage());
  }
}
