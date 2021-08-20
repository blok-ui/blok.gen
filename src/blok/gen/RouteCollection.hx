package blok.gen;

using tink.CoreApi;

abstract RouteCollection<T>(Array<Route<T>>) from Array<Route<T>> {
  public function new(pages) {
    this = pages;
  }

  public function match(url:String):Option<T> {
    for (route in this) switch route.match(url) {
      case Some(result): return Some(result);
      case None:
    }
    return None;
  }
}
