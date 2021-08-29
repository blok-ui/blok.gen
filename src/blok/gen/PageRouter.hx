package blok.gen;

import blok.core.foundation.routing.History;

using tink.CoreApi;

@service(fallback = throw 'No page router found')
class PageRouter implements State {
  @prop var history:History;
  @prop var routes:RouteContext<PageResult>;
  @prop var route:AsyncData<PageResult> = None;
  
  @init
  function setup() {
    addDisposable(history.getObservable().observe(match));
    __props.route = switch routes.match(history.getLocation()) {
      case Some(v): v;
      case None: None;
    }
  }

  public function setUrl(url) {
    history.push(url);
  }

  @update
  public function match(url:String) {
    return UpdateState({
      route: switch routes.match(url) {
        case Some(v): v;
        case None: None;
      }
    });
  }
}