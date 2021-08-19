package blok.gen;

using tink.CoreApi;

interface Route<T> {
  public function match(url:String):Option<RouteAction<T>>;
}
