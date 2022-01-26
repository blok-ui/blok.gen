package blok.gen.core;

using tink.CoreApi;
import blok.context.Service;
import blok.state.Observable;

enum DataHook {
  NoData;
  DataReady(url:String, data:Dynamic);
  DataExport(url:String, data:Dynamic);
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
