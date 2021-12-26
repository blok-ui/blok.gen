package blok.gen2.cache;

using DateTools;

/**
  The TimedCache will hold on to data for a given ammount of
  milleseconds.

  Note that the entire cache is cleared when *any* item becomes invalid,
  which ensures that data never gets out of sync. Each CacheItem has its own 
  lifetime, meaning that the cache is only cleared when the most stale item 
  is hit.

  Note: if you set `lifetime` to 0 you'll probably break your app.
**/
class TimedCache<T> implements Cache<T> {
  public inline static final ONE_MINUTE = 60000;
  public inline static final ONE_HOUR = 3600000;
  public inline static final ONE_DAY = 86400000;

  var lifetime:Float;
  var items:Map<String, CacheItem<T>> = [];

  public function new(lifetime) {
    this.lifetime = lifetime;
  }

	public function hit(key:String):Bool {
		if (!items.exists(key)) return false;
    if (items.get(key).invalid()) {
      clear();
      return false;
    }
    return true;
	}

	public function get(key:String):T {
		return items.get(key).get();
	}

	public function set(key:String, value:T, ?lifetime:Float) {
    if (lifetime == null) lifetime = this.lifetime;
    var time = Date.now().delta(lifetime);
    items.set(key, new CacheItem(value, time));
  }

	public function remove(key:String) {
    items.remove(key);
  }

  public function clear() {
    items.clear();
  }
}
