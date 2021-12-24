package blok.gen2.app;

import blok.gen2.core.Module;
import blok.gen2.core.Config;
import blok.gen2.routing.Matchable;
import blok.gen2.routing.RouteService;
import blok.gen2.routing.Router;

abstract class AppModule implements Module {
  var config:Config = null;
  
  public function new() {}

  public function getConfig() {
    if (config == null) {
      config = provideConfig();
    }
    return config;
  }

  abstract function provideConfig():Config;
  abstract function provideRoutes():Array<Matchable>;
  abstract function provideServices():Array<ServiceProvider>;
  #if blok.platform.static
    abstract function provideDataSources():Array<ServiceProvider>;
  #end

  public function register(context:Context) {
    context.addService(provideConfig());
    
    for (service in provideServices()) {
      context.addService(service);
    }
    
    #if blok.platform.static
      for (service in provideDataSources()) {
        context.addService(service);
      }
    #end

    context.addService(new RouteService(provideRoutes()));
    context.addService(new Router({ route: None }));
  }
}
