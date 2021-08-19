package blok.gen;

@service(fallback = throw 'No app service was found')
class AppService implements Service {
  // public final connection:Connection;
  public final errorPage:(message:String)->VNode;
  public final loadingPage:()->VNode;

  public function new(errorPage, loadingPage) {
    // this.connection = connection;
    this.errorPage = errorPage;
    this.loadingPage = loadingPage;
  }
}
