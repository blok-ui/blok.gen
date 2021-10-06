package blok.gen;

using tink.CoreApi;

class DataSourceTools {
  public static function toObservableResult<T>(promise:Promise<T>):ObservableResult<T, Error> {
    var obs = new ObservableResult(Suspended);
    promise.handle(o -> switch o {
      case Success(data): obs.resume(data);
      case Failure(failure): obs.fail(failure);
    });
    return obs;
  }
}
