package blok.gen2.cache;

using DateTools;

/**
  The TimedCache will hold on to data for a given ammount of
  time (provided in milleseconds).

  Note that the entire cache is cleared when *any* item becomes invalid,
  which ensures that data gets out of sync. Each CacheItem has its own 
  lifetime, however, which means that data is only cleared when the most
  stale item is hit.

  Note: if you set `lifetime` to 0 you'll probably break your app.
**/
class TimedCache<T> implements Cache<T> {
  public static final ONE_MINUTE = 60000;
  public static final ONE_HOUR = 3600000;
  public static final ONE_DAY = 86400000;

  var lifetime:Float;
  var items:Map<String, CacheItem<T>> = [];

  public function new(lifetime) {
    this.lifetime = lifetime;
  }

	public function hit(key:String):Bool {
		if (!items.exists(key)) return false;
    if (items.get(key).invalid()) {
      trace(key);
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

	public function remove(key:String) {}

  public function clear() {
    items.clear();
  }
}
