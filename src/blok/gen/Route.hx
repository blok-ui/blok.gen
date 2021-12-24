package blok.gen;

import haxe.ds.Option;

/**
  Blok Generator sites are built out of Routes. Generally, you'll use
  PageRoues, but you can use this lower-level class if needed.
**/
class Route<T> {
  var parent:Null<Route<T>>;
  final children:Array<Route<T>> = [];

  public function new() {}
  
  /**
    Set up the route.
  **/
  public function initializeRoute(?parent) {
    this.parent = parent;
  }

  /**
    Search up the Route tree to find a parent of the given type.
  **/
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

  /**
    Add a child to this route.

    By default, `Route.match` will iterate over these children and return
    the first one that matches.
  **/
  public function addChild(route:Route<T>) {
    route.initializeRoute(this);
    children.push(route);
  }

  /**
    Match the given URL. Returns `None` if no match, `Some<T>` if matched.
  **/
  public function match(url:String):Option<T> {
    if (children.length > 0) for (route in children) switch route.match(url) {
      case Some(result): return Some(result);
      case None:
    }
    return None;
  }
}
