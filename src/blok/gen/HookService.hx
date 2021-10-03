package blok.gen;

using tink.CoreApi;

enum SiteHook {
  NoSite;
  SiteLoading;
  SiteLoadingFailed(error:Error);
  SiteReady;
}

enum PageHook {
  NoPage;
  PageLoading(url:String);
  PageLoadingFailed(url:String, error:Error);
  PageReady(url:String, data:Dynamic, page:Page<Dynamic>);
}

@service(fallback = new HookService())
class HookService implements Service {
  public final site:Observable<SiteHook> = new Observable(NoSite);
  public final page:Observable<PageHook> = new Observable(NoPage);

  public function new() {}
}
