package blok.gen.datasource;

import js.Browser.window;

using tink.CoreApi;
using haxe.io.Path;

class HttpDataSource {
  final apiRoot:String;

  public function new(apiRoot) {
    this.apiRoot = apiRoot;
  }

  public function fetch(path:String) {
    var url = Path.join([ apiRoot, path ]);
    return window
      .fetch(url, { credentials: INCLUDE })
      .toPromise()
      .next(res -> res.json());
  }
}
