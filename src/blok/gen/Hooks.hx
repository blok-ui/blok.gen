package blok.gen;

class Hooks {
  public static function onLoading(build:()->VNode) {
    return HookService.use(hooks ->
      hooks.onLoadingStatusChanged.mapToVNode(status -> switch status {
        case Ready | Failed(_): null;
        case Loading: build();
      })
    );
  }

  public static function onLoadingError(build:(message:String, resume:()->Void)->VNode) {
    return HookService.use(hooks ->
      hooks.onLoadingStatusChanged.mapToVNode(status -> switch status {
        case Ready | Loading: null;
        case Failed(message): build(
          message,
          () -> hooks.onLoadingStatusChanged.update(Ready)
        );
      })
    );
  }
}
