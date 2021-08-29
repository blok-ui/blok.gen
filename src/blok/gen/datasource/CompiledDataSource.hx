package blok.gen.datasource;

import js.Browser.window;
import haxe.Json;

using Reflect;
using tink.CoreApi;
using blok.tools.ObjectTools;

class CompiledDataSource extends HttpDataSource {
  override public function fetch<T>(path:String):AsyncData<T> {
    var hashed = '__blok_gen_' + path.hash();
    if (window.hasField(hashed)) {
      return Ready(Json.parse(window.field(hashed)));
    }
    return super.fetch(path);
  }
}
