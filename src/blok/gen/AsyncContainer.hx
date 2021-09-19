package blok.gen;

using tink.CoreApi;

enum AsyncContainerStatus {
  Ready(vnode:VNode);
  Loading(promise:Promise<PageResult>);
}


class AsyncContainer extends Component {
  @prop var status:AsyncContainerStatus;
  @prop var wait:Int = 1000;
  @prop var loading:()->VNode;
  @prop var error:(e:String)->VNode;
  var previous:Null<VNode>;
  var link:Null<CallbackLink>;

  @dispose
  function cleanupLink() {
    if (link != null) link.cancel();
    link = null;
  }

  @update
  function setView(vnode:VNode) {
    return UpdateState({
      status: Ready(vnode)
    });
  }

  function render() {
    // Note: this is a bit messy and spaghetti-like. We need to rethink
    // how Suspend works.
    //
    // That, or we can just merge all of this nonsense into the PageRouter.
    return Context.use(context -> Suspend.await(
      () -> switch status {
        case Ready(vnode):
          previous = vnode;
        case Loading(promise):
          cleanupLink();
          Suspend.suspend(resume -> {
            HookService.from(context).onLoadingStatusChanged.update(Loading);
            link = promise.handle(o -> switch o {
              case Success(result):
                setView(result.view); 
                HookService.from(context).onLoadingStatusChanged.update(Ready);
                resume();
              case Failure(failure):
                #if blok.platform.static
                  throw failure;
                #end
                if (previous != null) {
                  setView(previous);
                  HookService.from(context).onLoadingStatusChanged.update(Failed(failure.message));
                } else {
                  setView(error(failure.message));
                }
                resume();
            });
          });
      },
      () -> {
        previous == null ? loading() : previous;
      }
    ));
  }
}
