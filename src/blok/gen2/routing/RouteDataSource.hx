package blok.gen2.routing;

import blok.gen2.core.Config;
import blok.gen2.core.HookService;
import blok.gen2.ui.PageLoader;
#if !blok.platform.static
  import blok.gen2.source.CompiledDataSource;
#end

using tink.CoreApi;
using blok.gen2.core.Tools;

/**
  This is a simple wrapper class that allows you to provide 
  data to a group of sub-routes (for example, you might use it
  to load site-wide configuration). An important note: the 
  loaders will ONLY run if a child route matches.

  It likely could use some improvement, but it'll do for now.
**/
class RouteDataSource<T> implements Matchable {
  final dataId:String;
  final loaders:Array<(context:Context)->Promise<Dynamic>>;
  final decode:(context:Context, data:Array<Dynamic>)->T;
  final provider:Null<(context:Context, data:T)->Void>;
  final collecton:RouteCollection;

  public function new(props:{
    id:String,
    #if blok.platform.static
      loaders:Array<(context:Context)->Promise<Dynamic>>,
    #end  
    decode:(context:Context, data:Array<Dynamic>)->T,
    provide:Null<(context:Context, data:T)->Void>,
    routes:Array<Matchable>
  }) {
    dataId = props.id;
    #if blok.platform.static
      loaders = props.loaders;
    #else
      loaders = [
        (context:Context) -> {
          var source = CompiledDataSource.from(context);
          var path = CompiledDataSource.getJsonDataPath(dataId);
          return (switch source.preload(path) {
            case Some(data): Promise.resolve(data);
            case None: source.fetch(path);
          }).next(data -> Promise.resolve(data[0]));
        }
      ];
    #end
    decode = props.decode;
    provider = props.provide;
    collecton = new RouteCollection(props.routes);
  }

  public function match(url:String):Option<RouteResult> {
    return switch collecton.match(url) {
      case Some(render): Some(context -> {
        var config = Config.from(context);
        
        return PageLoader.node({
          loading: config.view.loading,
          error: config.view.error,
          result: Promise
            .inParallel(loaders.map(load -> load(context)))
            .next(results -> {
              HookService.from(context).data.update(DataExport(dataId, results));
              decode(context, results);
            })
            .toObservableResult()
            .map(res -> switch res {
              case Suspended:
                Suspended;
              case Success(data):
                Success(Provider.provide({ 
                  register: context -> provider(context, data)
                }, render));
              case Failure(error):
                Failure(error);
            })
        });
      });
      case None: None;
    }
  }
}
