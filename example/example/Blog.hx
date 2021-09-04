package example;

import blok.gen.AppService;
import blok.gen.PageResult;
import blok.gen.Route;
import blok.gen.Config;
import blok.gen.ServiceFactory;
import example.page.*;
import example.ui.status.ErrorView;
import example.ui.status.LoadingView;

#if blok.platform.static
  using haxe.io.Path;
#end

final config = new Config({
  site: new SiteConfig({
    url: 'http://localhost:5000',  
    title: 'Test',
    rootId: 'root',
    assetPath: '/assets'
  }),
  #if blok.platform.static
    ssr: new SsrConfig({
      source: Path.join([ Sys.programPath().directory().directory(), 'example/data' ]),
      destination: Path.join([ Sys.programPath().directory(), 'www' ])
    })
  #end
});

final routes:Array<Route<PageResult>> = [
  new Home(),
  new Post(),
  new PostArchive()
];

final services:Array<ServiceFactory<PageResult>> = [
  ctx -> new AppService({
    loadingView: LoadingView.node,
    errorView: ErrorView.node,
    assets: [ 
      AssetCss('styles.css', true),
      AssetCss('https://cdn.jsdelivr.net/npm/bootstrap@5.1.0/dist/css/bootstrap.min.css', false)
    ]
  })
];

