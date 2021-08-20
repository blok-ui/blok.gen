package blok.gen.ssr;

import haxe.io.Path;
import blok.gen.data.Store;
import blok.gen.data.StoreService;
import blok.gen.data.ssr.SsrStore;
import blok.gen.storage.Reader;
import blok.core.foundation.routing.history.StaticHistory;

class SsrKernal implements Kernal {
  final appRoot:String;
  final reader:Reader;
  final config:Config;
  final formatters:FormatterCollection;
  final routesFactory:(store:Store)->Array<Route<VNode>>;

  public function new(appRoot, config, routesFactory, reader, formatters) {
    this.appRoot = appRoot;
    this.config = config;
    this.routesFactory = routesFactory;
    this.reader = reader;
    this.formatters = formatters;
  }

  public function run() {
    var store = new SsrStore(
      reader,
      new FileWriter(Path.join([ appRoot, config.apiRoot])),
      formatters
    );
    var visitor = new Visitor(
      config,
      url -> AppRoot.node({
        store: new StoreService(store),
        pages: new PageRouter({
          routes: routesFactory(store),
          history: new StaticHistory(url)
        }),
        // @todo: I really hate how this works -- it's a bad idea
        //        and super hard to configure
        app: new AppService(
          msg -> Html.text(msg), 
          () -> Html.text('loading')
        )
      }),
      new FileWriter(appRoot)
    );

    visitor.start();
  }
}
