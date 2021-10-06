package example.ui.layout;

import blok.gen.Config;
import blok.gen.Head;
import blok.gen.HookService;
import example.ui.elements.Container;
import example.ui.elements.Navbar;
import example.page.PostArchive;

using Blok;

class DefaultLayout extends Component {
  @prop var pageTitle:String;
  @prop var children:Array<VNode>;
  @use var config:Config;

  function render() {
    return [
      Head.node({
        siteTitle: config.site.title,
        pageTitle: pageTitle
      }),
      Navbar.container( 
        Navbar.brand(),
        Navbar.menu( 
          Navbar.option(
            PostArchive.link({
              page: 1,
              className: 'nav-link'
            }, Html.text('Archive'))
          )
        )
      ),
      HookService.use(hooks ->
        hooks.page.mapToVNode(status -> switch status {
          case NoPage | PageReady(_, _, _): null;
          case PageFailed(url, error, _):
            Html.div({
              className: 'alert alert-danger',
              role: 'alert',
              onclick: _ -> hooks.page.update(NoPage),
            }, Html.text('Failed to load: $url'),  Html.text(error.message));
          case PageLoading(_): 
            Html.div({
              className: 'alert alert-info',
              role: 'status'
            }, Html.text('Loading...'));
        })
      ),
      Container.main(...children)
    ];
  }
}
