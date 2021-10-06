package blok.gen;

using tink.CoreApi;

@service(fallback = throw 'No page router found')
class PageRouter implements State {
  @prop var routes:RouteContext<PageResult>;
  @prop var route:Option<PageResult> = None;
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
