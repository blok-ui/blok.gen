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

  public function generate(url:String):Promise<{
    data: Dynamic,
    html: String
  }> {
    return new Promise((res, rej) -> {
      var tracker = new SuspendTracker();
      var meta = new MetadataService(config);
      var ssrService = new SsrService();
      var root = Platform.render(
        Provider
          .factory()
          .provide(tracker)
          .provide(meta)
          .provide(ssrService)
          .render(context -> build(url)), 
        text -> null,
        e -> rej(new Error(500, e.toString())) 
      );

      tracker.status.observe(status -> switch status {
        case Ready | Waiting(0):
          trace('Ready: ${url}');
          res(wrap(meta, ssrService, root.toConcrete().join('')));
        case Waiting(num):
          trace('Waiting: ${num}');
      });
      
      return () -> null; // todo?
    });
  }
  
  function wrap(meta:MetadataService, ssr:SsrService, body:String) {
    var css = config.globalAssets
      .filter(c -> c.match(AssetCss(_)))
      .map(c -> switch c {
        case AssetCss(path): Path.join([ config.assetPath, path ]);
        default: null;
      });
    return {
      data: ssr.getData(),
      html:'
<!doctype html>
<html>
  <head>
    <title>${meta.getSite().title} | ${meta.getPage().title}</title>
    ${ [ for (path in css) '<link href="$path" rel="stylesheet" />' ].join('\n') }
  </head>
  <body>
    <div id="${config.rootId}">${body}</div>
    <script src="${config.getClientAppPath()}"></script>
  </body>
</html>
    '.trim()
    };
  }
}
