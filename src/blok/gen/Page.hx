package blok.gen;

import blok.VNode;

@:autoBuild(blok.gen.PageBuilder.build())
abstract class Page<T> extends Route<PageResult> {
  abstract public function decode(data:Dynamic):T;
  abstract public function render(data:T):VNode;

  public function getContext():RouteContext<PageResult> {
    return switch findParentOfType(RouteContext) {
      case Some(context): 
        context;
      case None:
        throw 'Could not find route context';
    }
  }
}
