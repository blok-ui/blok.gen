package blok.gen;

abstract class Kernal {
  final site:SiteModule;

  public function new(site) {
    this.site = site;
  }
  
  abstract function getModules():Array<Module<PageResult>>;

  public function createRouteContext():RouteContext<PageResult> {
    var context:RouteContext<PageResult> = new RouteContext();
    context.useModule(new CoreModule());
    context.useModule(site);
    for (module in getModules()) context.useModule(module);
    return context;
  }

  public function createApp(routes:RouteContext<PageResult>):VNode {
    return App.node({ routes: routes });
  }

  abstract public function run():Void;
}
