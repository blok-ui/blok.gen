package blok.gen.ssr;

import haxe.Json;
import haxe.io.Path;

using tink.CoreApi;

@service(fallback = null)
class Visitor implements Service {
  final generator:HtmlGenerator;
  final writer:FileWriter;
  final visited:Array<String> = [];
  var pending:Array<String> = [];

  public function new(config, build, writer) {
    this.generator = new HtmlGenerator(
      config,
      url -> Provider.provide(this, _ -> build(url))
    );
    this.writer = writer;
  }

  public function visit(link:String) {
    if (visited.contains(link) || pending.contains(link)) return;
    pending.push(link);
  }

  public function start() {
    visit('');
    run();
  }

  function run() {
    var toVisit = pending.copy();
    pending = [];
    Promise
      .inParallel(toVisit.map(generate))
      .handle(o -> switch o {
        case Success(_):
          if (pending.length > 0) run();
        case Failure(failure):
          // todo
          trace(failure);
      });
  }

  function generate(url) {
    visited.push(url);
    return generator
      .generate(url)
      .next(res -> {
        var name = url == '' ? 'index' : url;
        trace('Visiting: ${name}');
        writer.write(generateHtmlPath(url), res.html);
        writer.write(generateJsonPath(url), Json.stringify(res.data));
        Noise;
      });
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
