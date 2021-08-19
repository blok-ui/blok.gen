package blok.gen.data.client;

import js.Browser.window;

using tink.CoreApi;
using haxe.io.Path;

class ClientStore implements Store {
  final apiRoot:String;

  public function new(apiRoot) {
    this.apiRoot = apiRoot;
  }

  public function find<T:Model>(query:Query<T>):Promise<Array<T>> {
    var url = Path.join([ apiRoot, query.asJsonName() ]);
    return window
      .fetch(url, { credentials: INCLUDE })
      .toPromise()
      .next(res -> res.json())
      .next((data:Array<Dynamic>) -> data.map(query.meta.create));
  }
}
