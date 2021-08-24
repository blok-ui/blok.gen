package blok.gen;

import blok.VNode;

using tink.CoreApi;

// @todo: This is a mess ATM.
//        Try to rework this whole thing, where Route -> Page is similar to
//        VNode -> Component?
@:autoBuild(blok.gen.PageBuilder.build())
abstract class Page<T> {
  final config:Config;

  public function new(config) {
    this.config = config;
  }

  abstract public function decode(data:Dynamic):T;
  abstract public function render(meta:MetadataService, data:T):VNode;

  public function renderLoading():VNodeResult {
    return AppService.use(app -> app.loadingPage());
  }
}
