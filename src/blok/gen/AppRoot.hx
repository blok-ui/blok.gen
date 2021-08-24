package blok.gen;

class AppRoot extends Component {
  @prop var app:AppService;
  @prop var pages:PageRouter;

  function render() {
    return Provider
      .factory()
      .provide(app)
      .provide(pages)
      .render(context -> PageRouter.observe(context, router -> {
        switch router.route {
          case Some(action):
            ErrorBoundary.node({
              build: () -> action,
              catchError: e -> AppService.from(context).errorPage(e.message)
            });
          case None:
            AppService.from(context).errorPage('Page not found.');
        }
      }));
  }
}
