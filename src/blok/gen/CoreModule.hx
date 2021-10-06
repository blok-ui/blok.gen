package blok.gen;

class CoreModule implements Module<PageResult> {
  public function new() {}
  
  public function register(context:RouteContext<PageResult>) {
    context.addService(new HookService());
    // todo: more?
  }
}
