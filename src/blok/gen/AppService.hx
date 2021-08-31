package blok.gen;

import blok.gen.ui.DefaultLoadingView;
import blok.gen.ui.DefaultErrorView;

@service(fallback = getInstance())
class AppService implements Service {
  static var instance:Null<AppService> = null;

  static function getInstance() {
    if (instance == null) {
      instance = new AppService(
        () -> DefaultLoadingView.node({}),
        message -> DefaultErrorView.node({ message: message })
      );      
    }
    return instance;
  }

  final loadingView:()->VNode;
  final errorView:(message:String)->VNode;

  public function new(loadingView, errorView) {
    this.loadingView = loadingView;
    this.errorView = errorView;
  }

  public inline function renderLoading() {
    return loadingView();
  }

  public inline function renderError(message) {
    return errorView(message);
  }
}
