package example.ui.elements;

import blok.gen.Config;
import blok.gen.AsyncManager;
import example.page.Home;

using Blok;

class Navbar {
  public static function container(...children:VNode) {
    return Html.header({}, 
      Html.nav({ className: 'navbar navbar-dark bg-dark' }, 
        Html.div({ className: 'container' }, ...children)
      )
    );
  }

  public static function brand() {
    return Config.use(config ->
      Html.div({
        className: 'd-flex align-items-center'
      },
        Home.link({
          className: 'navbar-brand'
        }, Html.text(config.site.title))
      )
    );
  }

  public static function menu(...children:VNode) {
    return Html.ul({
      className: 'navbar-nav'
    }, ...children);
  }

  public static function option(...children:VNode) {
    return Html.li({
      className: 'nav-item'
    }, ...children);
  }
}
