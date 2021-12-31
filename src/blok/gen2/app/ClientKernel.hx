package blok.gen2.app;

#if !blok.platform.dom
  #error "ClientKernel may only be used with blok.platform.dom";
#end

import js.Browser;
import blok.context.Context;
import blok.dom.Platform;
import blok.foundation.routing.history.BrowserHistory;
import blok.gen2.core.Config;
import blok.gen2.core.Kernel;
import blok.gen2.source.HttpDataSource;
import blok.gen2.source.CompiledDataSource;
import blok.gen2.routing.HistoryService;

class ClientKernel extends Kernel {
  public function addCoreServices(context:Context) {
    context.addService(new HistoryService(new BrowserHistory()));
    context.addService(new HttpDataSource(config.site.url));
    context.addService(new CompiledDataSource());
  }

  public function run() {
    var context = createContext();
    
    Platform.hydrate(
      Browser.document.getElementById(config.site.rootId),
      bootstrap(context),
      root -> null
    );
  }
}
