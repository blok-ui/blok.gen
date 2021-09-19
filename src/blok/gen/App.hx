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
            Ready(result.view);
          case Failure(e): 
            Ready(AppService.from(context).renderError(e.message));
          case Loading(promise):
            Loading(promise);
          case None: 
            Ready(AppService.from(context).renderError('Page not found'));
        },
        loading: AppService.from(context).renderLoading,
        error: AppService.from(context).renderError
      });
    })));
  }
}
