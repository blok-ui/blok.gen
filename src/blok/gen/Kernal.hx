package blok.gen;

import blok.core.foundation.routing.History;

abstract class Kernal {
  final config:Config;
  final routes:Array<Route<PageResult>>;
  final serviceFactories:Array<ServiceFactory<PageResult>>;

  public function new(config, routes, ?serviceFactories) {
    this.config = config;
    this.routes = routes;
    this.serviceFactories = serviceFactories == null ? [] : serviceFactories;
  }

  public function addServiceFactory(factory:ServiceFactory<PageResult>) {
    serviceFactories.push(factory);
    return this;
  }

  public function createRouteContext() {
    var context = new RouteContext([ 
      config,
      new HistoryService(createHistory()),
      new MetadataService(config)
    ], routes);
    for (factory in serviceFactories) context.addService(factory(context));
    return context;
  }

  abstract public function createHistory():History;

  public function createApp(routes) {
    return App.node({ routes: routes });
  }

  abstract public function run():Void;
}
