package blok.gen;

import blok.core.foundation.suspend.Suspend;
import haxe.Timer;

using tink.CoreApi;

enum AsyncWrapperStatus {
  Ready(vnode:VNode);
  Pending(vnode:VNode);
  Loading(promise:Promise<PageResult>);
}

class AsyncWrapper extends Component {
  @prop var status:AsyncWrapperStatus;
  @prop var wait:Int = 1000;
  @prop var loading:()->VNode;
  @prop var error:(e:String)->VNode;
  var previous:Null<VNode>;
  var timer:Null<Timer>;
  var link:Null<CallbackLink>;

  @before
  function prepare() {
    cleanupTimer();
    switch status {
      case Ready(vnode):
        cleanupLink();
        previous = vnode;
      case Loading(_):
        cleanupLink();
        timer = Timer.delay(() -> switch __status {
          case WidgetValid: showLoading();
          default:
        }, wait);
      case Pending(_):
        previous = null;
    }
  }

  @dispose
  function cleanupTimer() {
    if (timer != null) timer.stop();
    timer = null;
  }

  @dispose
  function cleanupLink() {
    if (link != null) link.cancel();
    link = null;
  }

  @update
  function setView(vnode:VNode) {
    cleanupTimer();
    return UpdateStateSilent({
      status: Ready(vnode)
    });
  }

  @update
  function setPendingView(vnode:VNode) {
    cleanupTimer();
    return UpdateStateSilent({
      status: Pending(vnode)
    });
  }

  @update 
  function showLoading() {
    return UpdateState({
      status: Pending(loading())
    });
  }

  function render() {
    return Suspend.await(
      () -> switch status {
        case Pending(vnode) | Ready(vnode): 
          vnode;
        case Loading(promise):
          Suspend.suspend(resume -> {
            link = promise.handle(o -> switch o {
              case Success(result):
                setView(result.view);
                resume();
              case Failure(failure):
                setPendingView(error(failure.message));
                resume();
            });
          });
      },
      () -> previous == null ? loading() : previous
    );
  }
}
