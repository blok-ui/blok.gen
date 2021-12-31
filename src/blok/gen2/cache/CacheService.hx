package blok.gen2.cache;

import blok.context.Service;
import blok.core.Disposable;

/**
  Provides an app-wide Cache implementation. By default, we just use the
  service's fallback (which is a TimedCache that keeps items around for a 
  minute).

  If you want to override this behavior, just return a CacheService
  from your AppModule's `provideServices` callback.
**/
@service(fallback = new CacheService(new TimedCache(TimedCache.ONE_MINUTE)))
class CacheService implements Service implements Disposable {
  final cache:Cache<Dynamic>;

  public function new(cache:Cache<Dynamic>) {
    this.cache = cache;
  }

  public inline function getCache() {
    return cache;
  }

  public function dispose() {
    cache.clear();
  } 
}
