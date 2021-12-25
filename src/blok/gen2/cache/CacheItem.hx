package blok.gen2.cache;

class CacheItem<T> {
  final value:T;
  final lifetime:Date;

  public function new(value, lifetime) {
    this.value = value;
    this.lifetime = lifetime;
  }

  public inline function get():T {
    return value;
  }

  public function invalid():Bool {
    return lifetime.getTime() <= Date.now().getTime();
  }
}
