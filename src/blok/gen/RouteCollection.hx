package blok.gen;

using tink.CoreApi;

abstract RouteCollection<T>(Array<Route<T>>) from Array<Route<T>> {
  public function new(pages) {
    this = pages;
  }

  public function match(url:String):Option<RouteAction<T>> {
    for (route in this) switch route.match(url) {
      case Some(action): return Some(action);
      case None:
    }
    return None;
  }
}
