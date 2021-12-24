package blok.gen;

using StringTools;
using tink.CoreApi;
using blok.gen.PathTools;

/**
  RouteCollections allow you to bundle a number of routes
  together, optionally with a prefix.

  For example:

  ```haxe
    var routes = new RouteCollection([
      new ExampleRoute('bar')
    ], 'foo');

    var result = routes.match('foo/bar'); // -> Some(...)
  ```

  Note how the RouteCollection adds the prefix to all sub-routes.
**/
class RouteCollection<T> extends Route<T> {
  final prefix:Null<String>;

  public function new(children:Array<Route<T>>, ?prefix) {
    super();
    this.prefix = prefix;
    for (child in children) addChild(child);
  }

  override public function match(url:String):Option<T> {
    if (prefix != null) {
      if (!url.prepareUrl().startsWith(prefix)) return None;
      url = url.prepareUrl().substr(prefix.length);
    }
    return super.match(url);
  }
}
