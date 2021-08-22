package blok.gen.ssr;

import haxe.io.Path;
import blok.gen.data.Store;
import blok.gen.data.StoreService;
import blok.gen.data.ssr.SsrStore;
import blok.gen.storage.Reader;
import blok.core.foundation.routing.history.StaticHistory;

class SsrKernal implements Kernal {
  final ssrConfig:SsrConfig;
  final config:Config;
  final formatters:FormatterCollection;
  final routes:Array<Route<VNode>>;

  public function new(ssrConfig, config, routes, formatters) {
    this.ssrConfig = ssrConfig;
    this.config = config;
    this.routes = routes;
    this.formatters = formatters;
  }

  public function run() {
    var store = new SsrStore(
      new FileReader(ssrConfig.source),
      new FileWriter(Path.join([ ssrConfig.destination, config.apiRoot ])),
      formatters
    );
    var visitor = new Visitor(
      config,
      url -> AppRoot.node({
        store: new StoreService(store),
        pages: new PageRouter({
          routes: routes,
          history: new StaticHistory(url)
        }),
        // @todo: I really hate how this works -- it's a bad idea
        //        and super hard to configure
        app: new AppService(
          msg -> Html.text(msg), 
          () -> Html.text('loading')
        )
      }),
      new FileWriter(ssrConfig.destination)
    );

    visitor.start();
  }
}
