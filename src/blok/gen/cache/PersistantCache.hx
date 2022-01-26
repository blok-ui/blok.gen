package blok.gen.cache;

/**
  A Cache implementation that never goes stale (unless you call
  `clear` manually).
**/
class PersistantCache<T> implements Cache<T> {
  final data:Map<String, T> = [];

  public function new() {}

  public function hit(key:String):Bool {
    return data.exists(key);
  }

  public function get(key:String):T {
    return data.get(key);
  }

  public function set(key:String, value:T, ?lifetime:Float) {
    data.set(key, value);
  }

  public function remove(key:String) {
    data.remove(key);
  }

  public function clear() {
    data.clear();
  }
}
