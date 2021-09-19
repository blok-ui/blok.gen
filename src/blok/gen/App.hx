package blok.gen;

class App extends Component {
  @prop var routes:RouteContext<PageResult>;

  function render() {
    return routes.provide(context -> PageRouter.provide({
      routes: routes,
      history: HistoryService.from(context).getHistory()
    }, context -> PageRouter.observe(context, router -> {
      AsyncContainer.node({
        status: switch router.route.unwrap() {
          case Ready(result):
            #if blok.platform.static
              // We need to get this out of here and into some sort
              // of Hook. Right now this stuff is scattered all over
              // the place. Maybe inside the PageRouter is the right
              // idea?
              blok.gen.ssr.Visitor
                .from(context)
                .addResult(HistoryService.from(context).getLocation(), result);
            #end
            Ready(result.view);
          case Failure(e): 
            Ready(AppService.from(context).renderError(e.message));
          case Loading(promise):
            Loading(promise.next(result -> {
              #if blok.platform.static
                // Same thing with this:
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
