package blog;

import blok.VNode;
import blok.gen.data.Store;
import blok.gen.Config;
import blok.gen.Route;
import blog.pages.*;

final config = new Config({
  siteTitle: 'Test',
  rootId: 'root',
  assetPath: '/assets',
  apiRoot: '/api/v1'
});

function factory(store:Store):Array<Route<VNode>> return [
  new Home(store),
  new Post(store),
  new PostArchive(store)
];

