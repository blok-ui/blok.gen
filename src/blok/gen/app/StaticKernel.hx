package blok.gen.app;

#if !blok.platform.static
  #error "StaticKernel may only be used with blok.platform.static";
#end

import blok.context.Context;
import blok.foundation.routing.history.StaticHistory;
import blok.gen.routing.HistoryService;
import blok.gen.core.Kernel;
import blok.gen.build.Visitor;
import blok.gen.build.FileWriter;
import blok.gen.build.MetadataService;
import blok.gen.cli.Display;
import blok.gen.cli.NodeConsole;

using tink.CoreApi;

class StaticKernel extends Kernel {
  function addCoreServices(context:Context) {
    context.addService(new HistoryService(new StaticHistory('/')));
    context.addService(new MetadataService());
  }

  public function run() {
    // hooks.status.update(Generating);

    var display = new Display(new NodeConsole());
    var visitor = new Visitor(this, display);
    var writer = new FileWriter(config.ssr.destination);

    display.write('Building [ ${config.site.title} ]');
    display.work();

    visitor.visit('/');
    visitor.run().handle(o -> switch o {
      case Success(data):
        Promise.inParallel(data.map(result -> {
          writer.write(result.path, result.contents);
        })).handle(o -> switch o {
          case Success(_):
            // hooks.status.update(Complete(config));
            display.success('Build completed with no errors.');
            Sys.exit(0);
          case Failure(failure):
            display.error('Build failed with: ${failure.message}');
            Sys.exit(1);
        });
      case Failure(failure):
        display.error('Build failed with: ${failure.message}');
        Sys.exit(1);
    });
  }
}
