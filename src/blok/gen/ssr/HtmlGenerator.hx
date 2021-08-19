package blok.gen.ssr;

import blok.gen.Config;
import blok.ssr.Platform;
import blok.core.foundation.suspend.SuspendTracker;

using StringTools;
using haxe.io.Path;
using tink.CoreApi;

class HtmlGenerator {
  final config:Config;
  final build:(url:String)->VNode;

  public function new(config, build) {
    this.config = config;
    this.build = build;
  }

  public function generate(url:String):Promise<String> {
    return new Promise((res, rej) -> {
      var tracker = new SuspendTracker();
      var meta = new MetadataService(config);
      var root = Platform.render(
        Provider
          .factory()
          .provide(tracker)
          .provide(meta)
          .render(context -> build(url)), 
        text -> null,
        e -> rej(new Error(500, e.toString())) 
      );

      tracker.status.observe(status -> switch status {
        case Ready | Waiting(0):
          trace('Ready: ${url}');
          res(wrap(meta, root.toConcrete().join('')));
        case Waiting(num):
          trace('Waiting: ${num}');
      });
      
      return () -> null; // todo?
    });
  }
  
  function wrap(meta:MetadataService, body:String) {
    return '
<!doctype html>
<html>
  <head>
    <title>${meta.getSite().title} | ${meta.getPage().title}</title>
  </head>
  <body>
    <div id="${config.rootId}">${body}</div>
    <script src="${config.getClientAppPath()}"></script>
  </body>
</html>
    '.trim();
  }
}
