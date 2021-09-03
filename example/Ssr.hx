import nuke.Engine;
import blok.gen.Config;
import blok.gen.ssr.SsrKernal;
import blok.gen.ssr.FileWriter;
import example.Blog.config;
import example.Blog.routes;
import example.Blog.services;
import example.datasource.BlogPostDataSource;

using haxe.io.Path;

function main() {
  var kernal = new SsrKernal(config, routes, services);
  kernal.addServiceFactory(ctx -> new BlogPostDataSource(
    ctx.getService(Config).ssr.source
  ));
  kernal.onAfterGenerate(() -> {
    var styles = Engine.getInstance().stylesToString();
    var writer = new FileWriter(Path.join([ 
      config.ssr.destination,
      config.site.assetPath
    ]));
    writer.write('styles.css', styles);
  });
  kernal.run();
}
