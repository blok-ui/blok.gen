package blok.gen;

using Type;

class RouteContext<T> extends Route<T> {
  final context:Context = new Context();

  public function new(?services:Array<ServiceProvider>, children:Array<Route<T>>) {
    super();
    for (service in services) addService(service);
    for (child in children) addChild(child);
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
