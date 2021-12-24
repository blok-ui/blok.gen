package blok.gen2.routing;

using tink.CoreApi;

@service(fallback = throw 'No router found')
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
