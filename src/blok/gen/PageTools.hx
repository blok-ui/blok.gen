package blok.gen;

import blok.core.foundation.suspend.Suspend;
import blok.gen.async.SuspendablePromise;

using StringTools;
using haxe.io.Path;

class PageTools {
  public static function wrapPage<T>(page:Page<T>, suspendable:SuspendablePromise<T>) {
    return Suspend.await(
      () -> {
        var data = suspendable.get();
        return MetadataService.use(meta -> page.render(meta, data));
      },
      page.renderLoading
    );
  }

  public static function prepareUrl(url:String) {
    var normalized = url.normalize();
    if (normalized.startsWith('/')) normalized = normalized.substr(1);
    return normalized;
  }
}
