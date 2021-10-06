package blok.gen;

using StringTools;
using tink.CoreApi;
using blok.gen.PathTools;

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
