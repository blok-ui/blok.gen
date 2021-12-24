package blok.gen2.routing;

using tink.CoreApi;

@service(fallback = new RouteService([]))
class RouteService extends Matchable implements Service {
  public function new(routes:Array<Matchable>) {
    super();
    for (r in routes) addChild(r);
  }
}
