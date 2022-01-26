package blok.gen.routing;

using tink.CoreApi;

interface Matchable {
  public function match(url:String):Option<RouteResult>;
}
