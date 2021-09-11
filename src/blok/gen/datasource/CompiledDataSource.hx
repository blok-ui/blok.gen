package blok.gen.datasource;

import js.Browser.window;

using Reflect;
using tink.CoreApi;
using blok.gen.tools.PathTools;

@service(fallback = new CompiledDataSource())
class CompiledDataSource implements Service {
  @use var http:HttpDataSource;
  
  public function new() {}

  public function preload<T>(path:String):Option<T> {
    var hashed = path.toHashedProperty();
    if (window.hasField(hashed)) {
      return Some(window.field(hashed));
    }
    return None;
  }

  public function fetch<T>(path:String):Promise<T> {
    return http.fetch(path);
  }
}
