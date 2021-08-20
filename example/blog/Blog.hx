package blog;

import blok.VNode;
import blok.gen.data.Store;
import blok.gen.Config;
import blok.gen.Route;
import blog.pages.*;

final config = new Config({
  siteTitle: 'Test',
  siteUrl: 'http://localhost:5000',
  rootId: 'root',
  assetPath: '/assets',
  apiRoot: '/api/v1'
});

function factory(store:Store):Array<Route<VNode>> return [
  Home.route(),
  Post.route(),
  PostArchive.route()
];
