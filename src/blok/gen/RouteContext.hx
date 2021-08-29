package blok.gen;

using Type;

class RouteContext<T> extends Route<T> {
  final services:Map<String, ServiceProvider> = [];

  public function new(?services:Array<ServiceProvider>, children:Array<Route<T>>) {
    super();
    for (service in services) addService(service);
    for (child in children) addChild(child);
  }

  public function addService(service:ServiceProvider) {
    var name = Type.getClass(service).getClassName();
    services.set(name, service);
  }

  public function getService<T:ServiceProvider>(cls:Class<T>):Null<T> {
    var name = cls.getClassName();
    if (!services.exists(name)) {
      throw 'No service registered for $name';
    }
    return cast services.get(name);
  }

  public function register(context:Context) {
    for (service in services) {
      service.register(context);
    }
  }

  public function provide(cb) {
    return Provider.provide(this, cb);
  }
}
