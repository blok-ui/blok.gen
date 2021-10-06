package blok.gen;

interface Module<T> {
  public function register(context:RouteContext<T>):Void;
}
