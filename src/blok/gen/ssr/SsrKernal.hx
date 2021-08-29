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
    var writer = new FileWriter(config.ssrConfig.destination);

    visitor.visit('/');
    visitor.run().handle(o -> switch o {
      case Success(data): Promise.inParallel(data.map(result -> {
        Promise.inParallel([
          writer.write(result.jsonPath, result.json),
          writer.write(result.htmlPath, result.html)
        ]);
      })).handle(o -> switch o {
        case Success(_):
          Sys.println('Successfully compiled');
          Sys.exit(0);
        case Failure(failure):
          Sys.println('Failed: ${failure.message}');
          Sys.exit(1);
      });
      case Failure(failure):
        Sys.println('Failed: ${failure.message}');
        Sys.exit(1);
    });
  }
}
