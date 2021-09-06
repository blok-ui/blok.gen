package blok.gen.datasource;

import js.Browser.window;

using Reflect;
using tink.CoreApi;
using blok.gen.tools.PathTools;

@service(fallback = new CompiledDataSource())
class CompiledDataSource implements Service {
  @use var http:HttpDataSource;
  
  public function new() {}

  public function fetch<T>(path:String):AsyncData<T> {
    var hashed = path.toHashedProperty();
    if (window.hasField(hashed)) {
      return Ready(window.field(hashed));
    }
    return http.fetch(path);
  }
}
