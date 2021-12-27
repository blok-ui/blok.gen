package blok.gen2.app;

import blok.core.foundation.routing.history.StaticHistory;
import blok.gen2.routing.HistoryService;
import blok.gen2.core.Kernel;
import blok.gen2.ssr.Visitor;
import blok.gen2.ssr.FileWriter;
import blok.gen2.ssr.MetadataService;

using tink.CoreApi;

class StaticKernel extends Kernel {
	function addCoreServices(context:Context) {
    context.addService(new HistoryService(new StaticHistory('/')));
    context.addService(new MetadataService());
  }

	public function run() {
    // hooks.status.update(Generating);

    var visitor = new Visitor(this);
    var writer = new FileWriter(config.ssr.destination);

    Sys.println('');
    Sys.println('Starting to build "${config.site.title}":');
    Sys.println('');

    visitor.visit('/');
    visitor.run().handle(o -> switch o {
      case Success(data):
        Promise.inParallel(data.map(result -> {
          writer.write(result.path, result.contents);
        })).handle(o -> switch o {
          case Success(_):
            // hooks.status.update(Complete(config));
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
