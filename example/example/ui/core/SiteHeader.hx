package example.ui.core;

import blok.gen.Config;
import example.page.Home;

using Blok;

@lazy
class SiteHeader extends Component {
  @use var config:Config;

  function render() {
    return Html.header({},
      Home.link(
        Html.h2({}, Html.text(config.site.title))
      ),
      Html.ul({})  
    );
  }
}
