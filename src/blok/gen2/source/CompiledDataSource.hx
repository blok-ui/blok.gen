package blok.gen2.source;

import js.Browser.window;
import js.Browser.document;
import blok.context.Service;
import blok.gen2.core.HookService;
import blok.gen2.cache.CacheService;

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
  
  public function new() {}

  @init
  function preloadData() {
    if (window.hasField(dataProperty)) {
      var data:Dynamic = window.field(dataProperty);
      for (path in data.fields()) {
        cache.getCache().set(path, data.field(path));
      }
      window.deleteField(dataProperty);
      document.getElementById(dataProperty).remove();
    }
  }

  public function preload<T>(path:String):Option<T> {
    var c = cache.getCache();

    path = normalize(path);

    if (c.hit(path)) {
      return Some(c.get(path));
    }

    return None;
  }

  public inline function fetch<T>(path:String):Promise<T> {
    return http.fetch(path).next(data -> {
      trace(path);
      cache.getCache().set(path, data);
      return Promise.resolve(data);
    });
  }

  function normalize(path:String) {
    return path.normalize();
  }
}
