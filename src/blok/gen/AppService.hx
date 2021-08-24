package blok.gen;

@service(fallback = throw 'No app service was found')
class AppService implements Service {
  public final config:Config;
  public final errorPage:(message:String)->VNode;
  public final loadingPage:()->VNode;

  public function new(config, errorPage, loadingPage) {
    this.config = config;
    this.errorPage = errorPage;
    this.loadingPage = loadingPage;
  }
}
