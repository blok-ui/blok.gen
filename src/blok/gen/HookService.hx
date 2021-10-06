package blok.gen;

using tink.CoreApi;

enum PageHook {
  NoPage;
  PageLoading(url:String);
  PageFailed(url:String, error:Error, page:PageRoute<Dynamic>);
  PageReady(url:String, data:Dynamic, page:PageRoute<Dynamic>);
}

@service(fallback = new HookService())
class HookService implements Service {
  public final page:Observable<PageHook> = new Observable(NoPage);

  public function new() {}
}
