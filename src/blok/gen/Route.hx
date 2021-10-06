package blok.gen;

import haxe.ds.Option;

class Route<T> {
  var parent:Null<Route<T>>;
  final children:Array<Route<T>> = [];

  public function new() {}
  
  public function initializeRoute(?parent) {
    this.parent = parent;
  }

  public function findParentOfType<R:Route<T>>(kind:Class<R>):Option<R> {
    if (parent == null) {
      if (Std.isOfType(this, kind)) return Some(cast this);
      return None;
    }
    
    return switch (Std.downcast(parent, kind):Null<R>) {
      case null: parent.findParentOfType(kind);
      case found: Some(found);
    }
  }

  public function addChild(route:Route<T>) {
    route.initializeRoute(this);
    children.push(route);
  }

  public function match(url:String):Option<T> {
    if (children.length > 0) for (route in children) switch route.match(url) {
      case Some(result): return Some(result);
      case None:
    }
    return None;
  }
}
