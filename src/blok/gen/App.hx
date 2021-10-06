package blok.gen;

import tink.core.Error;

class App extends Component {
  @prop var routes:RouteContext<PageResult>;
  
  function render() {
    return routes.provide(context -> PageRouter.provide({ routes: routes }, context -> 
      PageRouter.observe(context, router -> switch router.route {
        case Some(result): 
          PageLoader.node({ 
            result: result,
            loading: Config.from(context).view.loading,
            error: Config.from(context).view.error 
          });
        case None:
          Config.from(context).view.error(new Error(404, 'No page found'));
      })
    ));
  }
}
