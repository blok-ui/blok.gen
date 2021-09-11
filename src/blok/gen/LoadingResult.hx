package blok.gen;

using tink.CoreApi;

enum LoadingResultStatus<T> {
  None;
  Loading(promise:Promise<T>);
  Ready(data:T);
  Failure(e:Error);
}

abstract LoadingResult<T>(LoadingResultStatus<T>) {
  @:from public static inline function ofPromise<T>(promise:Promise<T>) {
    return new LoadingResult(Loading(promise));
  }

  @:from public static inline function ofData<T>(data:T) {
    return new LoadingResult(Ready(data));
  }

  @:from public static inline function ofError<T>(error:Error):LoadingResult<T> {
    return new LoadingResult(Failure(error));
  }

  public static inline function ofNone<T>():LoadingResult<T> {
    return new LoadingResult(None);
  }

  public inline function new(status) {
    this = status;
  }

  public inline function unwrap():LoadingResultStatus<T> {
    return this;
  }
}
