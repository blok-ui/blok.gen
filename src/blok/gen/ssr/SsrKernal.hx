package blok.gen.ssr;

import blok.gen.cli.NodeConsole;
import blok.gen.cli.Display;

using tink.CoreApi;

class SsrKernal extends Kernal {
  public final hooks:SsrHooks = new SsrHooks();
  
  function getModules():Array<Module<PageResult>> {
    return [ new SsrModule() ];
  }

  public function run() {
    hooks.status.update(Generating);

    var display = new Display(new NodeConsole());
    var visitor = new Visitor(this, display);
    var config = site.getConfig();
    var writer = new FileWriter(config.ssr.destination);

    display.write('Building "${config.site.title}":');
    display.setStatus('Visiting routes...');
    display.work();

    visitor.visit('/');
    visitor.run().handle(o -> switch o {
      case Success(data): Promise.inParallel(data.map(result -> {
        writer.write(result.path, result.contents);
      })).handle(o -> switch o {
        case Success(_):
          hooks.status.update(Complete(config));
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