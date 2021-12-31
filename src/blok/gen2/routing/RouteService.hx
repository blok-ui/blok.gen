package blok.gen2.routing;

import blok.context.Service;

using tink.CoreApi;

@service(fallback = new RouteService([]))
class RouteService implements Matchable implements Service {
  final collection:RouteCollection;

  public function new(routes:Array<Matchable>) {
    collection = new RouteCollection(routes);
  }

  public function match(url:String):Option<RouteResult> {
    return collection.match(url);
  }
}
