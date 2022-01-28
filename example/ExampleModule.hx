import blok.context.ServiceProvider;
import blok.gen.core.Config;
import blok.gen.app.AppModule;
import blok.gen.content.ContentRenderer;
import blok.gen.routing.Scope;
import blok.gen.routing.Matchable;
import example.data.BlogConfig;
import example.ui.status.LoadingView;
import example.ui.status.ErrorView;

#if blok.platform.static
  import blok.gen.source.FileDataSource;
  import blok.gen.source.FormattedDataSource;
  import blok.gen.formatter.TomlFormatter;
  import blok.gen.formatter.MarkdownFormatter;
  import example.datasource.BlogPostDataSource;
#end

using Blok;
using Reflect;
using haxe.io.Path;
using tink.CoreApi;

class ExampleModule extends AppModule {
  function provideConfig():Config {
    return new Config({
      site: new SiteConfig({
        url: 'http://localhost:5000',  
        title: 'Test',
        rootId: 'root',
        assetPath: '/assets',
        assets: [
          AssetCss('styles.css', true),
          AssetCss('https://cdn.jsdelivr.net/npm/bootstrap@5.1.0/dist/css/bootstrap.min.css', false)
        ]
      }),
      view: new ViewConfig({
        error: e -> ErrorView.node({ message: e.message }),
        loading: () -> LoadingView.node({})
      }),
      #if blok.platform.static
        ssr: new SsrConfig({
          source: Path.join([ Sys.programPath().directory().directory(), 'example/data' ]),
          destination: Path.join([ Sys.programPath().directory().directory(), 'dist/www' ])
        })
      #end
    });
  }

  function provideRoutes():Array<Matchable> {
    return [
      new Scope<BlogConfig>({
        id: 'blog-data',
        #if blok.platform.static
          loaders: [ 
            (context) -> FormattedDataSource
              .from(context)
              .get('site.toml')
              .next(res -> Promise.resolve(res.formatted)),
          ],
        #end
        decode: (context, data:Array<Dynamic>) -> {
          return BlogConfig.fromJson(data[0]);
        },
        provide: (context, data) -> {
          context.addService(data);
        },
        routes: [
          new example.route.HomeRoute(),
          new example.route.PostRoute(),
          new example.route.PostArchiveRoute()
        ]
      })
    ];
  }

  function provideServices():Array<ServiceProvider> {
    return [
      ContentRenderer.withDefaults()
    ];
  }

  #if blok.platform.static 
    function provideDataSources():Array<ServiceProvider> {
      return [
        new FileDataSource(),
        new FormattedDataSource([
          'md' => new MarkdownFormatter(new TomlFormatter()),
          'toml' => new TomlFormatter()
        ]),
        new BlogPostDataSource()
      ];
    }
  #end
}