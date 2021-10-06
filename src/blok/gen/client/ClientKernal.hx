package blok.gen.client;

import js.Browser;
import blok.dom.Platform;

class ClientKernal extends Kernal {
  public function getModules():Array<Module<PageResult>> {
    return [ new ClientModule() ];
  }

  public function run() {
    var context = createRouteContext();
    var config = context.getService(Config);

    Platform.hydrate(
      Browser.document.getElementById(config.site.rootId),
      createApp(context),
      root -> null
    );
  }
}
