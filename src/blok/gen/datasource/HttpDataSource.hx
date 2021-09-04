package blok.gen.datasource;

import js.Browser.window;

using tink.CoreApi;
using haxe.io.Path;

class HttpDataSource implements DataSource {
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
