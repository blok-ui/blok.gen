package example.ui.layout;

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
      Container.main(...children)
    ];
  }
}
