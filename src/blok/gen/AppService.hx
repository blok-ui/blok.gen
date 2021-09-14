package blok.gen;

import blok.gen.ui.DefaultLoadingView;
import blok.gen.ui.DefaultErrorView;

// Todo: Should all of this just be rolled into Config?
//       Yes.

@service(fallback = getFallback())
class AppService implements Record implements Service {
  static var fallback:Null<AppService> = null;

  static function getFallback() {
    if (fallback == null) {
      fallback = new AppService({
        loadingView: DefaultLoadingView.node,
        errorView: DefaultErrorView.node
      });      
    }
    return fallback;
  }

  @prop var loadingView:(props:{}, ?key:Key)->VNode;
  @prop var errorView:(props:{ message:String }, ?key:Key)->VNode;
  @prop var assets:AssetCollection = new AssetCollection([]);

  public inline function renderLoading() {
    return loadingView({});
  }

  public inline function renderError(message) {
    return errorView({ message: message });
  }
}
