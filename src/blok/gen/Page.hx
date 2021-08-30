package blok.gen;

import blok.VNode;

@:autoBuild(blok.gen.PageBuilder.build())
abstract class Page<T> extends Route<PageResult> {
  abstract public function decode(data:Dynamic):T;
  abstract public function render(data:T):VNode;
  abstract public function metadata(data:T, meta:MetadataService):Void;

  public function getContext():RouteContext<PageResult> {
    return switch findParentOfType(RouteContext) {
      case Some(context): 
        context;
      case None:
        throw 'Could not find route context';
    }
  }

  final function createView(data:Dynamic):VNode {
    var parsed = decode(data);
    return MetadataService.use(meta -> {
      metadata(parsed, meta);
      render(parsed);
    });
  }
}
