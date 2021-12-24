package blok.gen2.app;

import js.Browser;
import blok.dom.Platform;
import blok.core.foundation.routing.history.BrowserHistory;
import blok.gen2.core.Config;
import blok.gen2.core.Kernel;
import blok.gen2.source.HttpDataSource;
import blok.gen2.source.CompiledDataSource;
import blok.gen2.routing.HistoryService;

class ClientKernel extends Kernel {
  public function addCoreServices(context:Context) {
    var config = Config.from(context);

    context.addService(new HistoryService(new BrowserHistory()));
    context.addService(new HttpDataSource(config.site.url));
    context.addService(new CompiledDataSource());
  }

  public function run() {
    var context = createContext();
    var config = Config.from(context);
    
    Platform.hydrate(
      Browser.document.getElementById(config.site.rootId),
      bootstrap(context),
      root -> null
    );
  }
}
