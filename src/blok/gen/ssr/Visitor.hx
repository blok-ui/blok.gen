package blok.gen.ssr;

import blok.gen.datasource.CompiledDataSource;
import blok.ssr.Platform;

using Lambda;
using tink.CoreApi;
using haxe.io.Path;

typedef VisitorResult = {
  public final path:String;
  public final contents:String;
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
            drain(results -> resume(results.concat(data.flatten())), reject);
          } else {
            resume(data.flatten());
          }
        case Failure(failure):
          // todo
          reject(failure);
      });
  }
  
  function generate(url:String):Promise<Array<VisitorResult>> {
    visited.push(url);

    var name = url == '' || url == '/' ? 'index' : url;
    
    Sys.println(' □ Visiting: ${name}');

    return new Promise((res, rej) -> {
      var context = kernal.createRouteContext();
      var history = context.getService(HistoryService);
      var suspend = context.getService(Suspend);
      var app = context.getService(AppService);
      var hooks = context.getService(HookService);
      var meta = context.getService(MetadataService);
      var config = context.getService(Config);

      history.setLocation(url);
      context.addService(this);

      var root = Platform.render(
        kernal.createApp(context), 
        html -> null, 
        e -> rej(new Error(500, e.toString()))
      );

      suspend.status.handle(status -> switch status {
        case Suspended:
          Sys.println(' ◧ Waiting on $name');
          Pending;
        case Complete:
          hooks.page.handle(status -> switch status {
            case PageReady(_, value, _):
              var data = haxe.Json.stringify(value #if debug , '  ' #end);
              Sys.println(' ■ Completed: $name');
              res([
                process(url, app, meta, config, data, cast root.toConcrete()),
                ({
                  path: generateJsonPath(url),
                  contents: data
                }:VisitorResult)
              ]);
              Handled;
            default:
              Sys.println(' ◧ Waiting on data for $name');
              Pending;
          });
          Handled;
      });

      () -> null; // ??
    });
  }

  function process(
    url:String, 
    app:AppService,
    meta:MetadataService,
    config:Config, 
    data:String,
    body:Array<String>
  ):VisitorResult {
    app.assets.addLocalJs('app.js');

    var html = new HtmlDocument({
      title: meta.getPageTitle(),
      head: [ for (asset in app.assets) switch asset {
        case AssetCss(path, local):
          if (local) path = Path.join([ config.site.url, config.site.assetPath, path ]);
          '<link rel="stylesheet" href="${path.withExtension('css')}"/>';
        case AssetPreload(path, local):
          if (local) path = Path.join([ config.site.url, path ]);
          '<link as="fetch" rel="preload" href="${path}"/>';
        case AssetJs(_, _):
          null;
      } ].filter(s -> s != null),
      body: [
        '<script id="${CompiledDataSource.dataProperty}">window.${CompiledDataSource.dataProperty} = $data</script>',
        '<div id="${config.site.rootId}">${body.join('')}</div>',
        [ for (asset in app.assets) switch asset {
          case AssetJs(path, local):
            if (local) path = Path.join([ config.site.url, config.site.assetPath, path ]);
            '<script src="${path}"></script>';
          default: null;
        } ].filter(s -> s != null).join('')
      ]
    });

    return {
      path: generateHtmlPath(url),
      contents: html.toHtml()
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
