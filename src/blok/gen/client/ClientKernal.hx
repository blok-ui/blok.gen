package blok.gen.client;

import js.Browser;
import blok.dom.Platform;
import blok.gen.data.Store;
import blok.gen.data.client.ClientStore;
import blok.core.foundation.routing.history.BrowserHistory;

class ClientKernal implements Kernal {
  final config:Config;
  final routesFactory:(store:Store)->Array<Route<VNode>>;

  public function new(config, routesFactory) {
    this.config = config;
    this.routesFactory = routesFactory;
  }
  
  public function run():Void {
    var store = new ClientStore(config.apiRoot);
    var meta = new MetadataService(config);

    Platform.mount(
      Browser.document.getElementById(config.rootId),
      Provider
        .factory()
        .provide(meta)
        .render(context -> AppRoot.node({
          pages: new PageRouter({
            routes: routesFactory(store),
            history: new BrowserHistory()
          }),
          // @todo: I really hate how this works -- it's a bad idea
          //        and super hard to configure
          app: new AppService(
            msg -> Html.text(msg), 
            () -> Html.text('loading')
          )
        }))
    );
  }
}
