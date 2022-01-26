package blok.gen.routing;

import blok.state.State;

using tink.CoreApi;

@service(fallback = new Router({ route: None }))
class Router implements State {
  @prop var route:Option<RouteResult>;
  @use var routes:RouteService;
  @use var history:HistoryService;

  @init
  function setup() {
    addDisposable(history.getHistory().getObservable().observe(match));
  }

  public function setUrl(url) {
    history.getHistory().push(url);
  }

  @update
  public function match(url:String) {
    return { route: routes.match(url) };
  }
}
