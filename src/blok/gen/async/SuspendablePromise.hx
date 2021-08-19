package blok.gen.async;

import haxe.Exception;
import blok.core.foundation.suspend.Suspend;

using tink.CoreApi;

@:forward(set, get)
abstract SuspendablePromise<T>(SuspendableObject<T>) {
  @:from public static function ofPromise<T>(promise:Promise<T>) {
    return new SuspendablePromise(Loading(promise));
  }

  @:from public static function ofDynamic<T>(value:T) {
    return new SuspendablePromise(Loaded(Success(value)));
  }

  inline public function new(status) {
    this = new SuspendableObject(status);
  }
}

private enum SuspendablePromiseResult<T> {
  Loading(promise:Promise<T>);
  Loaded(value:T);
  Failed(error:Error);
}

class SuspendableObject<T> {
  var status:SuspendablePromiseResult<T>;

  public function new(status) {
    set(status);
  }

  function set(status) {
    this.status = status;
  }

  public function get():Null<T> {
    return switch status {
      case Loading(promise):
        Suspend.suspend(resume -> {
          promise.handle(o -> switch o {
            case Success(data):
              set(Loaded(data));
              resume();
            case Failure(failure):
              set(Failed(failure));
              resume();
          });
        });
        null;
      case Failed(error):
        throw new Exception(error.message);
      case Loaded(data):
        data;
    }
  }
}
