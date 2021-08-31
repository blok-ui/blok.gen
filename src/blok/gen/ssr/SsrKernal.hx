package blok.gen.ssr;

import tink.CoreApi.Promise;
import blok.core.foundation.suspend.SuspendTracker;
import blok.core.foundation.routing.history.StaticHistory;

using haxe.io.Path;

class SsrKernal extends Kernal {
  override function createRouteContext():RouteContext<PageResult> {
    var context = super.createRouteContext();
    context.addService(new SuspendTracker());
    return context;
  }

  public function createHistory() {
    return new StaticHistory('/');
  }

  public function run() {
    var visitor = new Visitor(this);
    var writer = new FileWriter(config.ssr.destination);

    Sys.println('');
    Sys.println('Starting to build "${config.site.title}":');
    Sys.println('');

    visitor.visit('/');
    visitor.run().handle(o -> switch o {
      case Success(data): Promise.inParallel(data.map(result -> {
        Promise.inParallel([
          writer.write(result.jsonPath, result.json),
          writer.write(result.htmlPath, result.html)
        ]);
      })).handle(o -> switch o {
        case Success(_):
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
