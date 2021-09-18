package blok.gen.ssr;

import haxe.Json;
import blok.ssr.Platform;
import blok.core.foundation.suspend.SuspendTracker;

using StringTools;
using tink.CoreApi;
using haxe.io.Path;
using blok.tools.ObjectTools;
using blok.gen.tools.PathTools;

typedef VisitorResult = {
  public final htmlPath:String;
  public final html:String;
  public final jsonPath:String;
  public final json:String;
}

@service(isOptional)
class Visitor implements Service {
  final visited:Array<String> = [];
  final kernal:Kernal;
  final results:Map<String, PageResult> = [];
  var root:Null<ConcreteWidget>;
  var pending:Array<String> = [];

  public function new(kernal) {
    this.kernal = kernal;
  }

  public function visit(url:String) {
    if (visited.contains(url) || pending.contains(url)) return;
    pending.push(url);
  }

  public function addResult(url:String, result:PageResult) {
    results.set(url, result);
  }

  public function run() {
    return new Promise((res, rej) -> {
      drain(res, rej);
      () -> null;
    });
  }

  function drain(resume:(results:Array<VisitorResult>)->Void, reject) {
    var toVisit = pending.copy();
    pending = [];
    Promise
      .inParallel(toVisit.map(generate))
      .handle(o -> switch o {
        case Success(data):
          if (pending.length > 0) {
            drain(results -> resume(results.concat(data)), reject);
          } else {
            resume(data);
          }
        case Failure(failure):
          // todo
          reject(failure);
      });
  }

  function generate(url:String):Promise<VisitorResult> {
    visited.push(url);

    var name = url == '' || url == '/' ? 'index' : url;
    
    Sys.println(' □ Visiting: ${name}');

    return new Promise((res, rej) -> {
      var context = kernal.createRouteContext();
      var tracker = context.getService(SuspendTracker);
      var history = context.getService(HistoryService);
      var app = context.getService(AppService);
      var meta = context.getService(MetadataService);
      var config = context.getService(Config);

      history.setLocation(url);
      context.addService(this);

      var root = Platform.render(
        kernal.createApp(context), 
        html -> null, 
        e -> rej(new Error(500, e.toString()))
      );

      tracker.status.observe(status -> switch status {
        case Ready | Waiting(0):
          Sys.println(' ■ Completed: $name');
          res(wrap(url, app,  meta, config, root.toConcrete().join('')));
        case Waiting(num):
          Sys.println(' ◧ Waiting on: ${num} suspensions for $name');
      });

      () -> null; // ??
    });
  }

  function wrap(
    url:String, 
    app:AppService,
    meta:MetadataService, 
    config:Config, 
    body:String
  ):VisitorResult {
    // todo: metadata and stuff

    // the following is pretty messy, but...
    var head:Array<String> = [ for (asset in app.assets) switch asset {
      case AssetCss(path, local):
        if (local) path = Path.join([ config.site.url, config.site.assetPath, path ]);
        '<link rel="stylesheet" href="${path.withExtension('css')}"/>';
      case AssetJs(_, _):
        null;
    } ].filter(s -> s != null);
    var before:Array<String> = [];
    var after:Array<String> = [ for (asset in app.assets) switch asset {
      case AssetJs(path, local):
        if (local) path = Path.join([ config.site.url, config.site.assetPath, path ]);
        '<script src="${path}"></script>';
      default: null;
    } ].filter(s -> s != null);
    var jsonPath = generateJsonPath(url);
    var hashed = jsonPath.toHashedProperty();
    var result = results.get(url);
    var json = if (result != null) {
      before.push('<script id="$hashed">window.$hashed = ${Json.stringify(result.data)}</script>');
      #if debug Json.stringify(result.data, null, '  '); #else Json.stringify(result.data); #end
    } else '[]';
    var htmlPath = generateHtmlPath(url);
    var html = '
<!doctype html>
<html>
  <head>
    <title>${meta.getPageTitle()}</title>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width,initial-scale=1,minimum-scale=1">
    ${head.join('\n    ')}
  </head>
  <body>
    ${before.join('\n    ')}
    <div id="${config.site.rootId}">${body}</div>
    ${after.join('\n    ')}
    <script src="${Path.join([
      config.site.url,
      config.site.assetPath,
      'app.js'
    ])}"></script>
  </body>
</html>
    '.trim().replace('\r\n', '\n');

    return {
      htmlPath: htmlPath,
      html: html,
      jsonPath: jsonPath,
      json: json
    };
  }

  function generateHtmlPath(url:String) {
    if (url.length == 0) return 'index.html';
    return Path.join([ url, 'index.html' ]);
  }

  function generateJsonPath(url:String) {
    if (url.length == 0) return 'data.json';
    return Path.join([ url, 'data.json' ]);
  }
}
