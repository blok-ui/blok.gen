package blok.gen.datasource;

import js.Browser.window;
import js.Browser.document;

using Reflect;
using tink.CoreApi;
using blok.gen.tools.PathTools;

@service(fallback = new CompiledDataSource())
class CompiledDataSource implements Service {
  @use var http:HttpDataSource;
  
  public function new() {}

  public function preload<T>(path:String):Option<T> {
    // Note: ideally we'll be able to remove all of this --
    //       instead, we'll just use a `<link>` prefetch the data and
    //       use the HttpDataSource directly. That will have to wait until
    //       we figure out how to handle async stuff in our hydration though.
    var hashed = path.toHashedProperty();
    if (window.hasField(hashed)) {
      var data = window.field(hashed);
      window.deleteField(hashed);
      document.getElementById(hashed).remove();
      return Some(data);
    }
    return None;
  }

  public function fetch<T>(path:String):Promise<T> {
    return http.fetch(path);
  }
}
