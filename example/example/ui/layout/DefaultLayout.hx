package example.ui.layout;

import blok.gen.AsyncManager;
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
      // This is a terrible way to display a loading state, but it does
      // get across how it works:
      AsyncManager.onLoading(() -> Html.div({
        className: 'alert alert-info',
        role: 'status'
      }, Html.text('Loading...'))),
      // Errors will appear whenever an async request fails.
      AsyncManager.onError((message, dismiss) -> Html.div({
        className: 'alert alert-danger',
        role: 'alert',
        onclick: _ -> dismiss(),
      }, Html.text(message))),
      Container.main(...children)
    ];
  }
}
