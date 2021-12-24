package blok.gen2.core;

import blok.gen2.routing.HistoryService;
import blok.gen2.app.AppModule;
import blok.gen2.core.Config;
import blok.gen2.routing.Router;

using tink.CoreApi;

abstract class Kernel {
  final modules:Array<Module> = [];
  final config:Config;

  public function new(app:AppModule) {
    this.config = app.getConfig();
    addModule(app);
  }

  public function addModule(module:Module) {
    modules.push(module);
    return this;
  }

  abstract function addCoreServices(context:Context):Void;

  inline function addUserServices(context:Context) {
    for (module in modules) context.addService(module);
  }

  public function createContext():Context {
    var context = new Context();

    addCoreServices(context);
    addUserServices(context);

    return context;
  }

  public function bootstrap(context) {
    return Provider.forContext(context, context -> 
      Router.observe(context, router -> switch router.route {
        case Some(render):
          render(context);
        case None:
          var url = HistoryService.from(context).getLocation();
          var error = new Error(404, 'No page found at: $url');
          HookService.from(context).page.update(PageFailed(url, error));
          Config.from(context).view.error(error);
      })  
    );
  }

  abstract public function run():Void;
}
