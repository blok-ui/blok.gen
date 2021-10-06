package blok.gen.ssr;

using tink.CoreApi;

class SsrKernal extends Kernal {
  function getModules():Array<Module<PageResult>> {
    return [ new SsrModule() ];
  }

  public function run() {
    var visitor = new Visitor(this);
    var config = site.getConfig();
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