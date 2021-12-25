package blok.gen2.routing;

using tink.CoreApi;

interface Matchable {
  public function match(url:String):Option<RouteResult>;
}
