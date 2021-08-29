package blok.gen.ssr;

import haxe.Json;
import blok.ssr.Platform;
import blok.core.foundation.suspend.SuspendTracker;

using StringTools;
using tink.CoreApi;
using haxe.io.Path;
using blok.tools.ObjectTools;

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

    var name = url == '' ? 'index' : url;
    trace('Visiting: ${name}');

    return new Promise((res, rej) -> {
      var context = kernal.createRouteContext();
      var tracker = context.getService(SuspendTracker);
      var history = context.getService(HistoryService);
      var config = context.getService(ConfigService).getConfig();

      history.setLocation(url);
      context.addService(this);

      var root = Platform.render(
        kernal.createApp(context), 
        html -> null, 
        e -> rej(new Error(500, e.toString()))
      );

      tracker.status.observe(status -> switch status {
        case Ready | Waiting(0):
          trace('Done');
          res(wrap(url, config, root.toConcrete().join('')));
        case Waiting(num):
          trace('Waiting: ${num}');
      });

      () -> null; // ??
    });
  }

  function wrap(url:String, config:Config, body:String):VisitorResult {
    // todo: metadata and stuff

    // the following is pretty messy, but...
    var before:Array<String> = [];
    var jsonPath = generateJsonPath(url);
    var hashed = '__blok_gen_' + jsonPath.hash();
    var result = results.get(url);
    var json = if (result != null) {
      before.push('<script>window.$hashed = ${Json.stringify(result.data)}</script>');
      Json.stringify(result.data);
    } else '';
    var htmlPath = generateHtmlPath(url);
    var html = '
<!doctype html>
<html>
  <head>
    <title>${config.site.siteTitle}</title>
  </head>
  <body>
    ${before.join('\n    ')}
    <div id="${config.site.rootId}">${body}</div>
    <script src=""></script>
  </body>
</html>
    '.trim();

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
