package blok.gen;

import blok.core.foundation.routing.History;

abstract class Kernal {
  final config:Config;
  final routes:Array<Route<PageResult>>;
  final services:Array<(context:RouteContext<PageResult>)->ServiceProvider>;

  public function new(config, routes, ?services) {
    this.config = config;
    this.routes = routes;
    this.services = services == null ? [] : services;
  }

  public function createRouteContext() {
    var context = new RouteContext([ 
      config.asService(),
      new HistoryService(createHistory()) 
    ], routes);
    for (factory in services) context.addService(factory(context));
    return context;
  }

  abstract public function createHistory():History;

  public function createApp(routes) {
    return App.node({
      routes: routes,
      // todo
      error: e -> blok.Html.text(e),
      loading: blok.Html.text('loading')
    });
  }

  abstract public function run():Void;
}
