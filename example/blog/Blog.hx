package blog;

import blok.VNode;
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

final routes:Array<Route<VNode>> = [
  Home.route(),
  Post.route(),
  PostArchive.route()
];
