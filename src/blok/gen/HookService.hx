package blok.gen;

enum LoadingStatus {
  Ready;
  Loading;
  Failed(e:String);
}

/**
  Various hooks into the blok.generator lifecycle, loosely inspired by
  the way Wordpress does things. There aren't a lot now, but more 
  may be added as the library matures.

  Note that all hooks are blok.Observables, which means you can use
  them directly in your Components by calling their `mapToVNode` method.
**/
@service(fallback = new HookService())
class HookService implements Service {
  /**
    Updates whenever an asyncronous request is made.

    Note that this behavior is handled by the AsyncContainer, so you'll need
    to handle it yourself if you don't use the default setup.
  **/
  public final onLoadingStatusChanged:Observable<LoadingStatus> = new Observable(Ready);

  /**
    Triggers after a page has loaded, but *before* it has rendered.
  **/
  public final onPageLoaded:Observable<Null<{
    page:Page<Dynamic>,
    data:Dynamic
  }>> = new Observable(null);
  
  /**
    Triggers after a page has rendered.
  **/
  public final onPageRendered:Observable<Null<{
    page:Page<Dynamic>,
    widget:Widget
  }>> = new Observable(null);

  public function new() {}
}
