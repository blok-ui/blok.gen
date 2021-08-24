package blok.gen.data.client;

import js.Browser.window;

using tink.CoreApi;
using haxe.io.Path;

class ClientStore implements Store {
  final apiRoot:String;

  public function new(apiRoot) {
    this.apiRoot = apiRoot;
  }

  public function find<T:Model>(query:QueryBuilder<T>):Promise<StoreResult<T>> {
    var url = Path.join([ apiRoot, query.getJsonName() ]);
    return window
      .fetch(url, { credentials: INCLUDE })
      .toPromise()
      .next(res -> res.json())
      .next((result:StoreResult<Dynamic>) -> {
        meta: result.meta,
        data: result.data.map(query.meta.create)
      });
  }
}
