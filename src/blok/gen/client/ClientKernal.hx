package blok.gen.client;

import js.Browser;
import blok.dom.Platform;
import blok.core.foundation.routing.history.BrowserHistory;
import blok.gen.datasource.HttpDataSource;
import blok.gen.datasource.CompiledDataSource;

class ClientKernal extends Kernal {
  public function createHistory() {
    return new BrowserHistory();
  }

  override function createRouteContext():RouteContext<PageResult> {
    var context = super.createRouteContext();
    context.addService(new HttpDataSource(config.site.url));
    context.addService(new CompiledDataSource());
    return context;
  }

  public function run() {
    Platform.hydrate(
      Browser.document.getElementById(config.site.rootId),
      createApp(createRouteContext()),
      root -> null
    );
  }
}
