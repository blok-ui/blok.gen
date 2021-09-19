package blok.gen.ssr;

import tink.CoreApi.Promise;
import blok.core.foundation.routing.history.StaticHistory;

using haxe.io.Path;

class SsrKernal extends Kernal {
  final hooks:Array<()->Void> = [];

  public function createHistory() {
    return new StaticHistory('/');
  }

  public function onAfterGenerate(hook) {
    hooks.push(hook);
  }
  
  public function run() {
    var visitor = new Visitor2(this);
    var writer = new FileWriter(config.ssr.destination);

    Sys.println('');
    Sys.println('Starting to build "${config.site.title}":');
    Sys.println('');

    visitor.visit('/');
    visitor.run().handle(o -> switch o {
      case Success(data): Promise.inParallel(data.map(result -> {
        writer.write(result.path, result.contents);
      })).handle(o -> switch o {
        case Success(_):
          if (hooks.length > 0) {
            for (hook in hooks) hook();
          }

          Sys.println('');
          Sys.println('Build completed with no errors.');
          Sys.exit(0);
        case Failure(failure):
          Sys.println('');
          Sys.println('Build failed with: ${failure.message}');
          Sys.exit(1);
      });
      case Failure(failure):
        Sys.println('');
        Sys.println('Build failed with: ${failure.message}');
        Sys.exit(1);
    });
  }
}
