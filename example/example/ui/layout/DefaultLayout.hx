package example.ui.layout;

import blok.gen.HookService;
import example.ui.elements.Container;
import example.ui.elements.Navbar;
import example.page.PostArchive;

using Nuke;
using Blok;

class DefaultLayout extends Component {
  @:keep static final global = Css.global({
    body: {
      fontFamily: 'sans-serif',
      fontSize: 13.px()
    }
  });

  @prop var children:Array<VNode>;

  function render() {
    return [
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
        hooks.site.mapToVNode(status -> switch status {
          case NoSite | SiteReady: null;
          case SiteLoadingFailed(error):
            Html.div({
              className: 'alert alert-danger',
              role: 'alert',
              onclick: _ -> hooks.site.update(SiteReady),
            }, Html.text(error.message));
          case SiteLoading: 
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
