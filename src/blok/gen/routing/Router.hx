package blok.gen.routing;

import blok.gen.core.HookService;
import blok.state.State;

using tink.CoreApi;

@service(fallback = new Router({ route: None }))
class Router implements State {
  @prop var route:Option<RouteResult>;
  @prop var locked:Bool = false;
  @use var routes:RouteService;
  @use var history:HistoryService;
  @use var hooks:HookService;

  @init
  function setup() {
    addDisposable(hooks.site.observe(status -> switch status {
      case NoSite:
      case SiteHydrating: lock();
      case SiteReady: unlock();
    }));
    addDisposable(history.getHistory().getObservable().observe(match));
  }

  public function setUrl(url) {
    history.getHistory().push(url);
  }

  @update
  public function lock() {
    return { locked: true };
  }

  @update
  public function unlock() {
    return { locked: false };
  }

  @update
  public function match(url:String) {
    if (locked) return null;
    return { route: routes.match(url) };
  }
}
