package blok.gen2.source;

import js.Browser.window;
import js.Browser.document;

using tink.CoreApi;
using Reflect;

@service(fallback = new CompiledDataSource())
class CompiledDataSource implements Service {
  public inline static final dataProperty = '__blok_data';

  @use var http:HttpDataSource;
  
  public function new() {}

  public function preload<T>(path:String):Option<T> {
    if (window.hasField(dataProperty)) {
      var data = window.field(dataProperty);
      window.deleteField(dataProperty);
      document.getElementById(dataProperty).remove();
      return Some(data);
    }
    return None;
  }

  public inline function fetch<T>(path:String):Promise<T> {
    return http.fetch(path);
  }
}
