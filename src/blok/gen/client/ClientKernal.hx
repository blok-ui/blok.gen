package blok.gen.client;

import js.Browser;
import blok.dom.Platform;
import blok.core.foundation.routing.history.BrowserHistory;

class ClientKernal implements Kernal {
  final config:Config;
  final routes:Array<Route<VNode>>;

  public function new(config, routes) {
    this.config = config;
    this.routes = routes;
  }
  
  public function run():Void {
    var meta = new MetadataService(config);

    Platform.mount(
      Browser.document.getElementById(config.rootId),
      Provider
        .factory()
        .provide(meta)
        .render(context -> AppRoot.node({
          pages: new PageRouter({
            routes: routes,
            history: new BrowserHistory()
          }),
          // @todo: I really hate how this works -- it's a bad idea
          //        and super hard to configure
          app: new AppService(
            config,
            msg -> Html.text(msg), 
            () -> Html.text('loading')
          )
        }))
    );
  }
}
