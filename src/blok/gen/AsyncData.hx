package blok.gen;

using tink.CoreApi;

@:using(blok.gen.AsyncData.AsyncDataTools)
enum AsyncData<T> {
  None;
  Loading(promise:Promise<T>);
  Ready(data:T);
  Failed(e:Error);
}

class AsyncDataTools {
  public static function map<T, R>(data:AsyncData<T>, transform:(data:T)->R):AsyncData<R> {
    return switch data {
      case None: 
        None;
      case Loading(promise):
        Loading(promise.next(transform));
      case Ready(data):
        Ready(transform(data));
      case Failed(e):
        Failed(e);
    }
  }

  public static function flatMap<T, R>(data:AsyncData<T>, transform:(data:T)->AsyncData<R>):AsyncData<R> {
    return switch data {
      case None:
        None;
      case Ready(data):
        transform(data);
      case Loading(promise):
        Loading(promise.next(data -> new Promise((res, rej) -> {
          switch transform(data) {
            case None: res(cast null);
            case Ready(data): res(data);
            case Loading(promise): promise.handle(o -> switch o {
              case Success(data): res(data);
              case Failure(f): rej(f);
            });
            case Failed(e): rej(e);
          }
          () -> null;
        })));
      case Failed(e):
        Failed(e);
    }
  }

  public static function toPromise<T>(data:AsyncData<T>):Promise<T> {
    return new Promise((res, rej) -> {
      switch data {
        case None: 
          // noop?
        case Ready(data):
          res(data);
        case Loading(promise):
          promise.handle(o -> switch o {
            case Success(data): res(data);
            case Failure(e): rej(e);
          });
        case Failed(e):
          rej(e);
      }
      () -> null;
    });
  }
}
