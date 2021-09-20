package blok.gen;

import blok.gen.ui.DefaultLoadingView;
import blok.gen.ui.DefaultErrorView;

// @todo: Remove this service and roll it into Config.
//        We have too many dang classes right now.
@service(fallback = new AppService({
  loadingView: DefaultLoadingView.node,
  errorView: DefaultErrorView.node
}))
class AppService implements Record implements Service {
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
