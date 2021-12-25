package blok.gen2.ssr;

import haxe.Json;
import haxe.DynamicAccess;
import blok.ssr.Platform;
import blok.gen2.core.Config;
import blok.gen2.core.Kernel;
import blok.gen2.core.HookService;
import blok.gen2.source.CompiledDataSource;
import blok.gen2.routing.HistoryService;

using Lambda;
using tink.CoreApi;
using haxe.io.Path;
using Reflect;

typedef VisitorResult = {
  public final path:String;
  public final contents:String;
}

@service(isOptional)
class Visitor implements Service {
  final visited:Array<String> = [];
  final kernel:Kernel;
  final exportedData:Array<String> = [];
  var root:Null<ConcreteWidget>;
  var pending:Array<String> = [];

  public function new(kernel) {
    this.kernel = kernel;
  }
  
  public function visit(url:String) {
    if (visited.contains(url) || pending.contains(url)) return;
    pending.push(url);
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
    
    Sys.println(' □ Visiting [ ${name} ]');

    return new Promise((res:(data:Array<VisitorResult>)->Void, rej) -> {
      var context = kernel.createContext();
      var history = HistoryService.from(context);
      var hooks = HookService.from(context);
      var metadata = MetadataService.from(context);
      var config = Config.from(context);
      var bootstrapResults:DynamicAccess<Dynamic> = {};
      var dataResults:DynamicAccess<Dynamic> = {};
      var exports:Array<VisitorResult> = [];

      context.addService(this);
      history.setLocation(url);

      var addToBootstrap = (url:String, data:Dynamic) -> {
        var path = generateJsonPath(url);
        if (!bootstrapResults.exists(path)) {
          bootstrapResults.set(path, data);
        } else {
          var target = bootstrapResults.get(path);
          for (field in data.fields()) {
            target.setField(field, data.field(field));
          }
        }
      }

      var dataLink = hooks.data.observe(status -> switch status {
        case NoData: 
        case DataReady(matched, data) if (matched == url):
          Sys.println(' ◧ Local data for [ $matched ] received');
          addToBootstrap(matched, data);
          for (field in data.fields()) {
            dataResults.set(field, data.field(field));
          }
        case DataReady(matched, data):
          Sys.println(' ◧ Outside data for [ $matched ] received (boot only)');
          addToBootstrap(matched, data);
        case DataExport(matched, data):
          addToBootstrap(matched, data);
          var path = generateJsonPath(matched);
          if (!exportedData.contains(path)) {
            exportedData.push(path);
            Sys.println(' ◧ Parent data for [ $matched ] received (exporting)');
            exports.push({
              path: path,
              contents: Json.stringify(data)
            });
          } else {
            Sys.println(' ◧ Parent data for [ $matched ] received (already exported, added to boot)');
          }
      });

      var root = Platform.render(
        kernel.bootstrap(context), 
        html -> null, 
        e -> rej(new Error(500, e.toString()))
      );

      hooks.page.handle(status -> switch status {
        case PageReady(matched, value) if (matched == url):
          // var data = haxe.Json.stringify(value #if debug , '  ' #end);
          var bootData = haxe.Json.stringify(bootstrapResults #if debug , '  ' #end);
          var data = haxe.Json.stringify(dataResults #if debug , '  ' #end);
          Sys.println(' ■ [ $name ] completed');
          res([
            process(url, config, metadata, bootData, cast root.toConcrete()),
            ({
              path: generateJsonPath(url),
              contents: data
            }:VisitorResult)
          ].concat(exports));
          dataLink.dispose();
          Handled;
        case PageReady(matched, _):
          Sys.println(' ? [ $matched ] hit instead of expected [ ${url} ]');
          dataLink.dispose();
          rej(new Error(500, 'Invalid route reached'));
          Handled;
        case PageFailed(_, error):
          Sys.println(' X [ $name ] failed with ${error.message}');
          dataLink.dispose();
          rej(error);
          Handled;
        default:
          Sys.println(' ◧ [ $name ] processing...');
          Pending;
      });

      () -> null; // ??
    });
  }

  function process(
    url:String,
    config:Config,
    metadata:MetadataService, 
    data:String,
    body:Array<String>
  ):VisitorResult {
    config.site.assets.addLocalJs('app.js');

    var html = new HtmlDocument({
      title: metadata.title,
      head: [ for (asset in config.site.assets) switch asset {
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
        [ for (asset in config.site.assets) switch asset {
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
    if (url.length == 0) return '/index.html';
    return Path.join([ url, 'index.html' ]).normalize();
  }

  function generateJsonPath(url:String) {
    if (url.length == 0) return '/data.json';
    return Path.join([ url, 'data.json' ]).normalize();
  }
}
