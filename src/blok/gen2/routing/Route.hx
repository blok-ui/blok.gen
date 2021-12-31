package blok.gen2.routing;

import blok.context.Context;
import blok.context.Provider;
import blok.ui.VNode;
import blok.ui.Effect;
import blok.gen2.core.HookService;
import blok.gen2.core.Config;
import blok.gen2.ui.PageLoader;

using tink.CoreApi;
using blok.gen2.core.Tools;

/**
  The base of `blok.gen`'s routing system.

  Unlike other static site builders, `blok.gen` is *not* filesystem based.
  Instead, you define routes programatically. Each route requires four 
  callbacks to work: a `load` method (only for `blok.platform.static`)
  that gets the data from some data source (a file or database entry or
  something else), a decoder that parses the raw JSON from the data source
  into something useable by the final app, and a renderer that actually
  creates the final UI for the user.

  Defining a route is simple:

  ```haxe
  typedef HomeRoute = Route<'/', { name:String }>;
  ```

  If you need to get some params from the current URL, you can use the 
  following syntax:

  ```haxe
  typedef PostRoute = Route<'/post/{id:Int}', Post>;
  ```

  In the above example, the param `id` will be available in the for the
  `load` method. In addition, each route has a `link` or a
  `getUrl` method availabe. `link` will create a Component that can
  be used to navigate around your site (and which will hook into
  the Visitor used to generate the static app -- see `blok.gen2.ui.PageLink`
  for more), while `getUrl` just returns a string. Both cases are a 
  conveninet, type-safe way to handle navigation.

  ```haxe
  // `HomeRoute` has no params in its route, so: 
  var homeUrl = HomeRoute.getUrl({});
  // ... while `PostRoute` requires an `id` that's an Int
  var postUrl = PostRoute.getUrl({ id: 1 });
  ```

  See the example project for an idea of how this all looks in use.
**/
@:genericBuild(blok.gen2.routing.RouteBuilder.build())
class Route<@:const Url, T> {}

abstract class RouteBase<T> implements Matchable {
  function createResult(
    url:String,
    load:(context:Context)->Promise<Dynamic>,
    decode:(context:Context, data:Dynamic)->T,
    ?provider:(context:Context, data:T)->Void,
    render:(context:Context, data:T)->VNode
  ):RouteResult {
    return (context:Context) -> {
      var data = load(context).toObservableResult();
      var config = Config.from(context);
      var hooks = HookService.from(context);

      if (provider != null) {
        render = (context, data) -> Provider.provide(
          { register: context -> provider(context, data) },
          (context) -> render(context, data)
        );
      }

      return PageLoader.node({
        loading: config.view.loading,
        error: config.view.error,
        result: data.map(result -> switch result {
          case Suspended:
            hooks.page.update(PageLoading(url));
            Suspended;
          case Success(raw):
            var marked = false;
            var data = decode(context, raw);
            Success(Effect.withEffect(
              render(context, data),
              () -> if (!marked) {
                marked = true;
                hooks.page.update(PageReady(url, raw));
              }
            ));
          case Failure(error):
            Failure(error);
        })
      });
    };
  }
}
