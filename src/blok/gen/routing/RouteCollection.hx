package blok.gen.routing;

using tink.CoreApi;

class RouteCollection implements Matchable {
  final routes:Array<Matchable>;

  public function new(routes) {
    this.routes = routes;
  }
  
  public function withRoute(route:Matchable) {
    return new RouteCollection(routes.concat([ route ]));
  }

  public function match(url:String):Option<RouteResult> {
    if (routes.length > 0) for (route in routes) switch route.match(url) {
      case Some(result): return Some(result);
      case None:
    }
    return None;
  }
}
