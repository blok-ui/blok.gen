package blok.gen2.core;

using tink.CoreApi;

enum DataHook {
  NoData;
  DataReady(url:String, data:Dynamic);
}

enum PageHook {
  NoPage;
  PageLoading(url:String);
  PageFailed(url:String, error:Error);
  PageReady(url:String, data:Dynamic);
}

@service(fallback = new HookService())
class HookService implements Service {
  public final data:Observable<DataHook> = new Observable(NoData, (a, b) -> true);
  public final page:Observable<PageHook> = new Observable(NoPage);

  public function new() {}
}
