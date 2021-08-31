package blok.gen;

import blok.core.foundation.suspend.Suspend;

class App extends Component {
  @prop var routes:RouteContext<PageResult>;

  function render() {
    return routes.provide(context -> PageRouter.provide({
      routes: routes,
      history: HistoryService.from(context).getHistory()
    }, context -> PageRouter.observe(context, router -> switch router.route {
      case Ready(result):
        #if blok.platform.static
          blok.gen.ssr.Visitor
            .from(context)
            .addResult(HistoryService.from(context).getLocation(), result);
        #end
        AsyncWrapper.node({ 
          status: Ready(result.view),
          loading: AppService.from(context).renderLoading,
          error: AppService.from(context).renderError
        });
      case Failed(e): 
        AsyncWrapper.node({ 
          status: Ready(AppService.from(context).renderError(e.message)),
          loading: AppService.from(context).renderLoading,
          error: AppService.from(context).renderError
        });
      case Loading(promise):
        AsyncWrapper.node({ 
          status: Loading(promise.next(result -> {
            #if blok.platform.static
              blok.gen.ssr.Visitor
                .from(context)
                .addResult(HistoryService.from(context).getLocation(), result);
            #end
            result;
          })),
          loading: AppService.from(context).renderLoading,
          error: AppService.from(context).renderError
        });
        // var view:VNode = null;
        // Suspend.await(
        //   () -> if (view != null) {
        //     previous = view;
        //     AsyncWrapper.node({ 
        //       status: Ready(view),
        //       loading: AppService.from(context).renderLoading,
        //       error: AppService.from(context).renderError
        //     });
        //   } else {
        //     Suspend.suspend(resume -> {
        //       promise.handle(o -> switch o {
        //         case Success(result):
        //           #if blok.platform.static
        //             blok.gen.ssr.Visitor
        //               .from(context)
        //               .addResult(HistoryService.from(context).getLocation(), result);
        //           #end
        //           view = result.view;
        //           resume();
        //         case Failure(e): 
        //           view = AppService.from(context).renderError(e.message);
        //           resume();  
        //       });
        //     });
        //   },
        //   () -> AsyncWrapper.node({ 
        //     status: Loading(previous),
        //     loading: AppService.from(context).renderLoading
        //   })
        // );
      case None: 
        AsyncWrapper.node({ 
          status: Ready(AppService.from(context).renderError('Page not found')),
          loading: AppService.from(context).renderLoading,
          error: AppService.from(context).renderError
        });
    })));
  }
}
