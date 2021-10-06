package blok.gen;

abstract class SiteModule implements Module<PageResult> {
  var config:Config = null;

  public function new() {}

  public function getConfig() {
    if (config == null) {
      config = provideConfig();
    }
    return config;
  }

  abstract function provideConfig():Config;
  abstract function provideRoutes(context:Context):Array<PageRoute<Dynamic>>;
  abstract function provideServices(context:Context):Array<ServiceProvider>;
  #if blok.platform.static 
    abstract function provideDataSources(context:Context):Array<ServiceProvider>;
  #end

  public function register(context:RouteContext<PageResult>) {
    context.addService(provideConfig());
    for (service in provideServices(context.getContext())) {
      context.addService(service);
    }
    #if blok.platform.static
      for (service in provideDataSources(context.getContext())) {
        context.addService(service);
      }
    #end
    for (route in provideRoutes(context.getContext())) {
      context.addChild(route);
    }
  }
}
