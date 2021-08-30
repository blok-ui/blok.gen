package blok.gen.client;

import js.Browser;
import blok.dom.Platform;
import blok.core.foundation.routing.history.BrowserHistory;
import blok.gen.datasource.CompiledDataSource;

class ClientKernal extends Kernal {
  public function createHistory() {
    return new BrowserHistory();
  }

  override function createRouteContext():RouteContext<PageResult> {
    var context = super.createRouteContext();
    context.addService(new CompiledDataSource(config.site.url));
    return context;
  }

  public function run() {
    var context = createRouteContext();
    var config = context.getService(ConfigService).getConfig();
    var app = createApp(context);
    Platform.hydrate(
      Browser.document.getElementById(config.site.rootId),
      app
    );
  }
}
