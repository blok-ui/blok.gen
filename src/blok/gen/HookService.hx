package blok.gen;

import blok.GenApi.PageRoute;
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
  PageFailed(url:String, error:Error, page:PageRoute<Dynamic>);
  PageReady(url:String, data:Dynamic, page:PageRoute<Dynamic>);
}

@service(fallback = new HookService())
class HookService implements Service {
  public final site:Observable<SiteHook> = new Observable(NoSite);
  public final page:Observable<PageHook> = new Observable(NoPage);

  public function new() {}
}
