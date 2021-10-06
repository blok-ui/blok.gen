package blok.gen;

using Type;

class RouteContext<T> extends Route<T> {
  final context:Context = new Context();

  public function new(?services:Array<ServiceProvider>, ?children:Array<Route<T>>) {
    super();
    if (services != null) for (service in services) addService(service);
    if (children != null) for (child in children) addChild(child);
  }

  public function useModule(module:Module<T>) {
    module.register(this);
  }

  public inline function addService(service:ServiceProvider) {
    service.register(context);
  }

  public inline function getService<T:ServiceProvider>(cls:ServiceResolver<T>):Null<T> {
    return context.getService(cls);
  }

  public function getContext() {
    return context;
  }

  public function provide(cb) {
    return Provider.forContext(context, cb);
  }
}
