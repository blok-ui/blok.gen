import blok.context.ServiceProvider;
import blok.gen2.core.Config;
import blok.gen2.routing.Matchable;
import blok.gen2.app.AppModule;
import blok.gen2.content.ContentRenderer;
import blok.gen2.routing.Scope;
import example.data.BlogConfig;
import example.ui.page.Post;
import example.ui.page.PostArchive;
import example.ui.page.Home;
import example.ui.status.LoadingView;
import example.ui.status.ErrorView;

#if blok.platform.static
  import blok.gen2.source.FileDataSource;
  import blok.gen2.source.FormattedDataSource;
  import blok.gen2.formatter.TomlFormatter;
  import blok.gen2.formatter.MarkdownFormatter;
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
          destination: Path.join([ Sys.programPath().directory(), 'www' ])
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
          example.route.HomeRoute.create((context, data) -> Home.node({
            posts: data
          })),
          example.route.PostRoute.create((context, data) -> Post.node({
            next: data.next,
            prev: data.prev,
            post: data.current
          })),
          example.route.PostArchiveRoute.create((context, data) -> PostArchive.node({
            page: data.page,
            totalPosts: data.totalPosts,
            totalPages: data.totalPages,
            posts: data.posts
          }))
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