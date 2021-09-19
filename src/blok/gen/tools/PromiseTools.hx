package blok.gen.tools;

using tink.CoreApi;

class PromiseTools {
  public static function suspend<T>(promise:Promise<T>):SuspendableData<T> {
    var data:SuspendableData<T> = SuspendableData.suspended();
    promise.handle(o -> switch o {
      case Success(value): data.set(value);
      case Failure(failure): throw failure; // ??
    });
    return data;
  }  
}
