package blok.gen.datasource;

import js.Browser.window;
import blok.gen.Config;

using tink.CoreApi;
using haxe.io.Path;

@service(fallback = new HttpDataSource(Config.from(context).site.url))
class HttpDataSource implements Service {
  final root:String;

  public function new(root) {
    this.root = root;
  }

  public function fetch<T>(path:String):AsyncData<T> {
    var url = Path.join([ root, path ]);
    return Loading(window
      .fetch(url, { credentials: INCLUDE })
      .toPromise()
      .next(res -> res.json()));
  }
}
