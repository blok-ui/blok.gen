package blok.gen.ssr;

import blok.core.foundation.routing.history.StaticHistory;

class SsrModule implements Module<PageResult> {
  public function new() {}

  public function register(context:RouteContext<PageResult>) {
    context.addService(new HistoryService(new StaticHistory('/')));
    context.addService(new MetadataService());
  }
}
