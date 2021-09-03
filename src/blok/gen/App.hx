package blok.gen;

class App extends Component {
  @prop var routes:RouteContext<PageResult>;

  function render() {
    return routes.provide(context -> PageRouter.provide({
      routes: routes,
      history: HistoryService.from(context).getHistory()
    }, context -> PageRouter.observe(context, router -> {
      AsyncContainer.node({
        status: switch router.route {
          case Ready(result):
            #if blok.platform.static
              blok.gen.ssr.Visitor
                .from(context)
                .addResult(HistoryService.from(context).getLocation(), result);
            #end
            Ready(result.view);
          case Failed(e): 
            Ready(AppService.from(context).renderError(e.message));
          case Loading(promise):
            Loading(promise.next(result -> {
              #if blok.platform.static
                blok.gen.ssr.Visitor
                  .from(context)
                  .addResult(HistoryService.from(context).getLocation(), result);
              #end
              result;
            }));
          case None: 
            Ready(AppService.from(context).renderError('Page not found'));
        },
        loading: AppService.from(context).renderLoading,
        error: AppService.from(context).renderError
      });
    })));
  }
}
