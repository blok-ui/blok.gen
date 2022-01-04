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
        HookService.use(hooks -> hooks.page.mapToVNode(status -> switch status {
          case PageLoading(_): Html.div(
            {
              className: 'spinner-border',
              role: 'status',
              style: 'border-right-color:#fff;'
            },
            Html.span({ className: 'visually-hidden' }, 
              Html.text('Loading...')
            )
          );
          default: null;
        })),
        Navbar.menu( 
          Navbar.option(
            PostArchiveRoute.link({
              page: 1,
              className: 'nav-link'
            }, Html.text('Archive'))
          )
        )
      ),
      Container.main(...children)
    ];
  }
}
