package blok.gen.datasource;

import haxe.ds.Option;
import js.Browser.window;
import js.Browser.document;
import tink.core.Error;

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

  public inline function fetch<T>(path:String):ObservableResult<T, Error> {
    return http.fetch(path);
  }
}
