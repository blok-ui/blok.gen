package blok.gen;

import blok.VNode;

@:autoBuild(blok.gen.PageBuilder.build())
abstract class Page<T> extends Route<PageResult> {
  abstract public function decode(data:Dynamic):T;
  abstract public function render(data:T):VNode;
  abstract public function metadata(data:T, meta:MetadataService):Void;

  public inline function getService<T:ServiceProvider>(resolver:ServiceResolver<T>):T {
    return getContext().getService(resolver);
  }

  public function getContext():Context {
    return switch findParentOfType(RouteContext) {
      case Some(context): 
        context.getContext();
      case None:
        throw 'Could not find route context';
    }
  }

  final function createView(data:Dynamic):VNode {
    var result = decode(data);
    var hooks = getService(Hooks);
    
    hooks.onPageLoaded.update(this);

    return MetadataService.use(meta -> {
      metadata(result, meta);
      var vnode = render(result);
      hooks.onPageRendered.update(this);
      vnode;
    });
  }
}
