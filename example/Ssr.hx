import blok.gen.ConfigService;
import blok.gen.ssr.SsrKernal;
import example.Blog.config;
import example.Blog.routes;
import example.datasource.BlogPostDataSource;

using haxe.io.Path;

function main() {
  var kernal = new SsrKernal(config, routes);
  kernal.addServiceFactory(ctx -> new BlogPostDataSource(
    ctx.getService(ConfigService).getConfig().ssrConfig.source
  ));
  kernal.run();
}
