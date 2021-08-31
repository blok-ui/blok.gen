package blok.gen.datasource;

import js.Browser.window;

using Reflect;
using tink.CoreApi;
using blok.tools.ObjectTools;

@service(fallback = new CompiledDataSource(Config.from(context).site.url))
class CompiledDataSource extends HttpDataSource implements Service {
  override public function fetch<T>(path:String):AsyncData<T> {
    var hashed = '__blok_gen_' + path.hash();
    if (window.hasField(hashed)) {
      return Ready(window.field(hashed));
    }
    return super.fetch(path);
  }
}
