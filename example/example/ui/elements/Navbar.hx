package example.ui.elements;

import example.page.Home;
import haxe.io.Path;
import blok.gen.Config;

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
    return Config.use(config -> Home.link({
      className: 'navbar-brand d-flex align-items-center'
    }, Html.text(config.site.title)));
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
