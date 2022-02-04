package blok.gen.build;

import haxe.Json;
import haxe.DynamicAccess;
import blok.ssr.Platform;
import blok.context.Service;
import blok.ui.*;
import blok.gen.core.Config;
import blok.gen.core.Kernel;
import blok.gen.core.HookService;
import blok.gen.source.CompiledDataSource;
import blok.gen.routing.HistoryService;
import blok.gen.cli.Display;

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
  final display:Display;
  final exportedData:Array<String> = [];
  var root:Null<ConcreteWidget>;
  var pending:Array<String> = [];

  public function new(kernel, display) {
    this.kernel = kernel;
    this.display = display;
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
    
    return new Promise((res:(data:Array<VisitorResult>)->Void, reject) -> {
      var context = kernel.createContext();
      var history = HistoryService.from(context);
      var hooks = HookService.from(context);
      var metadata = MetadataService.from(context);
      var config = Config.from(context);
      var bootstrapResults:DynamicAccess<Dynamic> = {};
      var dataResults:DynamicAccess<Dynamic> = {};
      var exports:Array<VisitorResult> = [];
      var rej = (e:Error) -> {
        reject(new Error(e.code, e.message + ' (when rendering ${url})'));
      }

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
          display.setStatus('Local data for "$matched" received');
          addToBootstrap(matched, data);
          for (field in data.fields()) {
            dataResults.set(field, data.field(field));
          }
        case DataReady(matched, data):
          display.setStatus('Outside data for "$matched" received (boot only)');
          addToBootstrap(matched, data);
        case DataExport(matched, data):
          addToBootstrap(matched, data);
          var path = generateJsonPath(matched);
          if (!exportedData.contains(path)) {
            exportedData.push(path);
            display.setStatus('Parent data for "$matched" received (exporting)');
            exports.push({
              path: path,
              contents: Json.stringify(data)
            });
          } else {
            display.setStatus('Parent data for "$matched" received (already exported, added to boot)');
          }
      });

      var root = Platform.render(
        kernel.bootstrap(context), 
        html -> null, 
        e -> {
          dataLink.dispose();
          rej(new Error(500, e.toString()));
        }
      );

      hooks.page.handle(status -> switch status {
        case PageReady(matched, value) if (matched == url):
          var bootData = haxe.Json.stringify(bootstrapResults #if debug , '  ' #end);
          var data = haxe.Json.stringify(dataResults #if debug , '  ' #end);
          display.setStatus('Route "$name" complete');
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
          dataLink.dispose();
          rej(new Error(500, 'Invalid route reached: "$matched" hit instead of expected "$url"'));
          Handled;
        case PageFailed(_, error):
          dataLink.dispose();
          rej(error);
          Handled;
        default:
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
