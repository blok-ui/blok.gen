package blok.gen2.routing;

using tink.CoreApi;

class RouteCollection implements Matchable {
  final children:Array<Matchable> = [];

  public function new(routes:Array<Matchable>) {
    for (r in routes) addChild(r);
  }
  
  public function addChild(route:Matchable) {
    children.push(route);
  }

  public function match(url:String):Option<RouteResult> {
    if (children.length > 0) for (route in children) switch route.match(url) {
      case Some(result): return Some(result);
      case None:
    }
    return None;
  }
}
