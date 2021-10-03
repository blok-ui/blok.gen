package blok.gen;

class Hooks {
  public static function onLoading(build:()->VNode) {
    return HookService.use(hooks ->
      hooks.site.mapToVNode(status -> switch status {
        case NoSite | SiteReady | SiteLoadingFailed(_): null;
        case SiteLoading: build();
      })
    );
  }

  public static function onLoadingError(build:(message:String, resume:()->Void)->VNode) {
    return HookService.use(hooks ->
      hooks.site.mapToVNode(status -> switch status {
        case NoSite | SiteReady | SiteLoading: null;
        case SiteLoadingFailed(error): build(
          error.message,
          () -> hooks.site.update(SiteReady)
        );
      })
    );
  }
}
