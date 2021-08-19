package blok.gen.ssr;

import haxe.io.Path;
import blok.gen.storage.Writer;

using tink.CoreApi;

@service(fallback = null)
class Visitor implements Service {
  final generator:HtmlGenerator;
  final writer:Writer;
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
      .next(html -> {
        var name = url == '' ? 'index' : url;
        trace('Visiting: ${name}');
        writer.write(generatePath(url), html);
        Noise;
      });
  }

  function generatePath(url:String) {
    if (url.length == 0) return 'index.html';
    return Path.join([ url, 'index.html' ]);
  }
}
