package blok.gen;

import blok.html.Hydratable;
#if blok.platform.dom
  import blok.dom.Hydrator.hydrateChildren;
#end

using tink.CoreApi;

class PageLoader extends Component implements Hydratable {
  @prop var wait:Int = 1000;
  @prop var loading:()->VNode;
  @prop var error:(e:Error)->VNode;
  @prop var result:ObservableResult<VNode, Error>;
  var previous:Null<VNode>;
  
  #if blok.platform.dom
    public function hydrate(
      firstNode:js.html.Node,
      registerEffect:(effect:()->Void)->Void,
      next:()->Void
    ) {
      result.handle(result -> switch result {
        case Suspended:
          Pending;
        case Success(_) | Failure(_):
          hydrateChildren(
            this,
            __performRender().toArray(),
            getPlatform(),
            firstNode,
            registerEffect,
            next
          );
          Handled;
      });
    }
  #end

  function render() {
    return result.render(result -> switch result {
      case Suspended if (previous == null): 
        loading();
      case Suspended: 
        previous;
      case Success(view):
        previous = view;
        view;
      case Failure(e):
        error(e);
    });
  }
}
