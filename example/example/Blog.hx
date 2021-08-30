package example;

import blok.gen.PageResult;
import blok.gen.Route;
import blok.gen.Config;
import example.page.*;

#if blok.platform.static
  using haxe.io.Path;
#end

final config = new Config({
  site: new SiteConfig({
    url: 'http://localhost:5000',  
    siteTitle: 'Test',
    siteUrl: 'http://localhost:5000',
    rootId: 'root',
    assetPath: '/assets'
  }),
  #if blok.platform.static
    ssrConfig: new SsrConfig({
      source: Path.join([ Sys.programPath().directory().directory(), 'example/data' ]),
      destination: Path.join([ Sys.programPath().directory(), 'www' ])
    })
  #end
});

final routes:Array<Route<PageResult>> = [
  new Home(),
  new Post()
];
