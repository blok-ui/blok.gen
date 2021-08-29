package blok.gen.client;

import js.Browser;
import blok.dom.Platform;
import blok.core.foundation.routing.history.BrowserHistory;

class ClientKernal extends Kernal {
  public function createHistory() {
    return new BrowserHistory();
  }

  public function run() {
    var context = createRouteContext();
    var config = context.getService(ConfigService).getConfig();
    var app = createApp(context);
    Platform.mount(
      Browser.document.getElementById(config.site.rootId),
      app
    );
  }
}
