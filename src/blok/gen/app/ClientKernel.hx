package blok.gen.app;

#if !blok.platform.dom
  #error "ClientKernel may only be used with blok.platform.dom";
#end

import js.Browser;
import blok.context.Context;
import blok.dom.Platform;
import blok.foundation.routing.history.BrowserHistory;
import blok.gen.core.Kernel;
import blok.gen.core.HookService;
import blok.gen.source.HttpDataSource;
import blok.gen.source.CompiledDataSource;
import blok.gen.routing.HistoryService;

class ClientKernel extends Kernel {
  public function addCoreServices(context:Context) {
    context.addService(new HistoryService(new BrowserHistory()));
    context.addService(new HttpDataSource(config.site.url));
    context.addService(new CompiledDataSource());
  }

  public function run() {
    var context = createContext();
    var hooks = HookService.from(context);

    hooks.site.update(SiteHydrating);
    
    Platform.hydrate(
      Browser.document.getElementById(config.site.rootId),
      bootstrap(context),
      root -> hooks.site.update(SiteReady)
    );
  }
}
