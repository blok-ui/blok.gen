package blok.gen.source;

import js.Browser.window;
import js.Browser.document;
import blok.context.Service;
import blok.gen.core.HookService;
import blok.gen.cache.CacheService;
import blok.gen.cache.PersistantCache;

using StringTools;
using Reflect;
using tink.CoreApi;
using haxe.io.Path;

@service(fallback = new CompiledDataSource())
class CompiledDataSource implements Service {
  public static function getJsonDataPath(url:String) {
    return Path.join([ url, 'data.json' ]);
  }

  public inline static final dataProperty = '__blok_data';

  @use var http:HttpDataSource;
  @use var hooks:HookService;
  @use var cache:CacheService;

  var isHydrating:Bool = false;
  var hydrationCache:PersistantCache<Dynamic> = new PersistantCache();
  
  public function new() {}

  @init
  function preloadData() {
    hooks.site.handle(status -> switch status {
      case NoSite: 
        Pending;
      case SiteHydrating:
        isHydrating = true;
        if (window.hasField(dataProperty)) {
          var data:Dynamic = window.field(dataProperty);
          for (path in data.fields()) {
            hydrationCache.set(path, data.field(path));
          }
          window.deleteField(dataProperty);
          document.getElementById(dataProperty).remove();
        }
        Pending;
      case SiteReady:
        isHydrating = false;
        for (path in hydrationCache.getKeys()) {
          cache.getCache().set(path, hydrationCache.get(path));
        }
        hydrationCache = null;
        Handled;
    });
  }

  public function preload<T>(path:String):Option<T> {
    var c = isHydrating ? hydrationCache : cache.getCache();

    path = normalize(path);

    if (c.hit(path)) {
      return Some(c.get(path));
    }

    return None;
  }

  public inline function fetch<T>(path:String):Promise<T> {
    return http.fetch(path).next(data -> {
      cache.getCache().set(path, data);
      return Promise.resolve(data);
    });
  }

  function normalize(path:String) {
    return path.normalize();
  }
}
