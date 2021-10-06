package example;

import blok.gen.PageRoute;
import blok.ServiceProvider;
import blok.gen.Config;
import blok.gen.SiteModule;
import blok.gen.data.ContentRenderer;
import example.data.BlogConfig;
import example.page.*;

#if blok.platform.static
  import blok.gen.datasource.FileDataSource;
  import blok.gen.datasource.FormattedDataSource;
  import blok.gen.datasource.file.TomlFormatter;
  import blok.gen.datasource.file.MarkdownFormatter;
  import example.datasource.BlogPostDataSource;

  using haxe.io.Path;
#end

using Blok;

class Site extends SiteModule {
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

  function provideRoutes(context:Context):Array<PageRoute<Dynamic>> {
    return [
      new Home(),
      new PostArchive(BlogConfig.from(context).perPage),
      new Post()
    ];
  }
  
  function provideServices(context:Context):Array<ServiceProvider> {
    return [
      new BlogConfig({ perPage: 2 }),
      ContentRenderer.withDefaults(),
    ];
  }

  #if blok.platform.static 
    function provideDataSources(context:Context):Array<ServiceProvider> {
      return [
        new FileDataSource(Config.from(context).ssr.source),
        new FormattedDataSource([
          'md' => new MarkdownFormatter(new TomlFormatter())
        ]),
        new BlogPostDataSource()
      ];
    }
  #end
}