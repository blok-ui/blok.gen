package blok.gen;

enum AsyncManagerStatus {
  Ready;
  Loading;
  Failure(message:String);
}

@service(fallback = new AsyncManager({ status: Ready }))
class AsyncManager implements State {
  public static function onLoading(build:()->VNode) {
    return use(manager -> switch manager.status {
      case Loading: build();
      default: null;
    });
  }

  public static function onError(build:(message:String, dismiss:()->Void)->VNode) {
    return use(manager -> switch manager.status {
      case Failure(message): build(message, () -> manager.setStatus(Ready));
      default: null;
    });
  }

  @prop public var status:AsyncManagerStatus;

  @update
  public function setStatus(status) {
    return UpdateState({ status: status });
  }
}
