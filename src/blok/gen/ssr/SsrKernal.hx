package blok.gen.ssr;

import blok.core.foundation.routing.history.StaticHistory;

class SsrKernal implements Kernal {
  final config:Config;
  final formatters:FormatterCollection;
  final routes:Array<Route<VNode>>;

  public function new(config, routes, formatters) {
    this.config = config;
    this.routes = routes;
    this.formatters = formatters;
  }

  public function run() {
    var visitor = new Visitor(
      config,
      url -> AppRoot.node({
        pages: new PageRouter({
          routes: routes,
          history: new StaticHistory(url)
        }),
        // @todo: I really hate how this works -- it's a bad idea
        //        and super hard to configure
        app: new AppService(
          config,
          msg -> Html.text(msg), 
          () -> Html.text('loading')
        )
      }),
      new FileWriter(config.ssr.destination)
    );
    visitor.start();
  }
}
