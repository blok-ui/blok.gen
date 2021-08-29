package blok.gen;

import blok.core.foundation.suspend.Suspend;

class App extends Component {
  @prop var routes:RouteContext<PageResult>;
  @prop var loading:VNode;
  @prop var error:(e:String)->VNode;

  function render() {
    return routes.provide(context -> PageRouter.provide({
      routes: routes,
      history: HistoryService.from(context).getHistory()
    }, context -> switch PageRouter.from(context).route {
      case Ready(result):
        #if blok.gen.ssr
          blok.gen.ssr.Visitor
            .from(context)
            .addResult(HistoryService.from(context).getLocation(), result);
        #end
        result.view;
      case Failed(e): 
        error(e.message);
      case Loading(promise):
        var view:VNode = null;
        Suspend.await(
          () -> if (view != null) {
            view;
          } else {
            Suspend.suspend(resume -> {
              promise.handle(o -> switch o {
                case Success(result):
                  #if blok.gen.ssr
                    blok.gen.ssr.Visitor
                      .from(context)
                      .addResult(HistoryService.from(context).getLocation(), result);
                  #end
                  view = result.view;
                  resume();
                case Failure(e): 
                  view = error(e.message);
                  resume();  
              });
            });
          },
          () -> loading
        );
      case None: 
        error('Not found');
    }));
  }
}
