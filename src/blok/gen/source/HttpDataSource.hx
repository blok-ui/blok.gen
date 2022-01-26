package blok.gen.source;

import js.Browser.window;
import blok.context.Service;
import blok.gen.core.Config;

using tink.CoreApi;
using haxe.io.Path;

@service(fallback = new HttpDataSource(Config.from(context).site.url))
class HttpDataSource implements Service {
  final root:String;

  public function new(root) {
    this.root = root;
  }

  public function fetch<T>(path:String):Promise<T> {
    var url = Path.join([ root, path ]);
    return window
      .fetch(url, { credentials: INCLUDE })
      .then(res -> res.json());
  }
}
