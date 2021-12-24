package blok.gen2.routing;

using tink.CoreApi;

class Matchable {
  var parent:Null<Matchable>;
  final children:Array<Matchable> = [];

  public function new() {}

  public function initialize(?parent) {
    this.parent = parent;
  }

  public function findParentOfType<R:Matchable>(kind:Class<R>):Option<R> {
    if (parent == null) {
      if (Std.isOfType(this, kind)) return Some(cast this);
      return None;
    }
    
    return switch (Std.downcast(parent, kind):Null<R>) {
      case null: parent.findParentOfType(kind);
      case found: Some(found);
    }
  }

  public function addChild(route:Matchable) {
    route.initialize(this);
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
