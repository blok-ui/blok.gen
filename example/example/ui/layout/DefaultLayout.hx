package example.ui.layout;

import blok.gen2.core.Config;
import blok.gen2.core.HookService;
import blok.gen2.ui.Head;
import example.data.BlogConfig;
import example.ui.elements.Container;
import example.ui.elements.Navbar;
import example.route.PostArchiveRoute;

using Blok;

class DefaultLayout extends Component {
  @prop var pageTitle:String;
  @prop var children:Array<VNode>;
  @use var config:Config;
  @use var blogConfig:BlogConfig;

  function render() {
    return [
      Head.node({
        siteTitle: blogConfig.name,
        pageTitle: pageTitle
      }),
      Navbar.container( 
        Navbar.brand(),
        Navbar.menu( 
          Navbar.option(
            PostArchiveRoute.link({
              page: 1,
              className: 'nav-link'
            }, Html.text('Archive'))
          )
        )
      ),
      HookService.use(hooks ->
        hooks.page.mapToVNode(status -> switch status {
          case NoPage | PageReady(_, _): null;
          case PageFailed(url, error):
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
