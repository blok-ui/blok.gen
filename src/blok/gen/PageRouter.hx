package blok.gen;

import blok.core.foundation.routing.History;

using tink.CoreApi;

@service(fallback = null)
class PageRouter implements State {
  @prop var history:History;
  @prop var routes:RouteCollection<VNode>;
  @prop var route:Option<RouteAction<VNode>> = None;

  @init
  function setup() {
    addDisposable(history.getObservable().observe(match));
    __props.route = routes.match(history.getLocation());
  }

  public function setUrl(url) {
    history.push(url);
  }

  @update
  public function match(url:String) {
    return UpdateState({
      route: routes.match(url)
    });
  }
}
