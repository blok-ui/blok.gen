package blok.gen;

import haxe.Exception;

class ErrorBoundary extends Component {
  @prop var build:()->VNode;
  @prop var catchError:(e:Exception)->VNodeResult;

  public function render() {
    return build();
  }

  override function componentDidCatch(exception:Exception):VNodeResult {
    return catchError(exception);
  }
}
