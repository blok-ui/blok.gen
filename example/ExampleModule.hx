import blok.ServiceProvider;
import blok.gen2.core.Config;
import blok.gen2.routing.Matchable;
import blok.gen2.app.AppModule;
import blok.gen2.content.ContentRenderer;
import blok.gen2.routing.RouteDataSource;
import example.route.PostRoute;
import example.route.PostArchiveRoute;
import example.route.PostArchiveRoute.decode as decodePostArchive;
import example.route.HomeRoute;
import example.data.BlogConfig;
import example.data.BlogPost;
import example.ui.page.Post;
import example.ui.page.PostArchive;
import example.ui.page.Home;

#if blok.platform.static
  import blok.gen2.source.FileDataSource;
  import blok.gen2.source.FormattedDataSource;
  import blok.gen2.formatter.TomlFormatter;
  import blok.gen2.formatter.MarkdownFormatter;
  import example.datasource.BlogPostDataSource;

  using haxe.io.Path;
  using blok.gen.data.PaginationTools;
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
        error: e -> Html.text(e.message),
        loading: () -> Html.text('loading...')
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
      new RouteDataSource<BlogConfig>({
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
          new HomeRoute({
            #if blok.platform.static
              load: (context:Context) -> BlogPostDataSource
                .from(context)
                .findPosts(0, BlogConfig.from(context).perPage),
            #end
            decode: (context:Context, data:Dynamic) -> (data.field('data'):Array<Dynamic>).map(BlogPost.fromJson),
            render: (context:Context, data:Array<BlogPost>) -> Home.node({ posts: data })
          }),

          new PostRoute({
            #if blok.platform.static
              load: (context:Context, id:String) -> BlogPostDataSource
                .from(context)
                .getPost(id),
            #end
            decode: (context, data:Dynamic) -> {
              var meta:{ next:Dynamic, prev:Dynamic } = data.field('meta');
              return {
                next: if (meta.next != null) BlogPost.fromJson(meta.next) else null,
                prev: if (meta.prev != null) BlogPost.fromJson(meta.prev) else null,
                current: BlogPost.fromJson(data.field('data'))
              }
            },
            render: (context, data) -> Post.node({
              next: data.next,
              prev: data.prev,
              post: data.current
            })
          }),
    
          new PostArchiveRoute({
            #if blok.platform.static
              load: (context:Context, page:Int) -> {
                var perPage = BlogConfig.from(context).perPage;
                return BlogPostDataSource
                  .from(context)
                  .findPosts(page.toIndex(perPage), perPage);
              },
            #end
            decode: (context, data) -> decodePostArchive(data, BlogConfig.from(context).perPage),
            render: (context, data) -> PostArchive.node({
              page: data.page,
              totalPosts: data.totalPosts,
              totalPages: data.totalPages,
              posts: data.posts
            })
          })
        ]
      })
    ];
	}

	function provideServices():Array<ServiceProvider> {
    return [
      ContentRenderer.withDefaults(),
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