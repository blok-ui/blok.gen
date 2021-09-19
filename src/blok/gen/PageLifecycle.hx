package blok.gen;

class PageLifecycle<T> extends Component {
  @prop var page:Page<T>;
  @prop var data:T;
  @prop var child:VNode;
  @use var hooks:HookService;
  @use var meta:MetadataService;

  @before
  function onLoaded() {
    hooks.onPageLoaded.update({
      page: page,
      data: data
    });
  }

  @effect
  function onRendered() {
    hooks.onPageRendered.update({
      page: page,
      widget: this
    });
  }

  function render() {
    return child;
  }
}
