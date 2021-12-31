package blok.gen.client;

import blok.gen.datasource.HttpDataSource;
import blok.gen.datasource.CompiledDataSource;
import blok.foundation.routing.history.BrowserHistory;

class ClientModule implements Module<PageResult> {
  public function new() {}

  public function register(context:RouteContext<PageResult>) {
    var config = context.getService(Config);

    context.addService(new HistoryService(new BrowserHistory()));
    context.addService(new HttpDataSource(config.site.url));
    context.addService(new CompiledDataSource());
  }
}
