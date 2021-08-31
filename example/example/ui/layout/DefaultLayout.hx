package example.ui.layout;

import example.ui.core.SiteHeader;

using Blok;

class DefaultLayout extends Component {
  @prop var children:Array<VNode>;

  function render() {
    return [
      SiteHeader.node({}),
      Html.main({}, ...children)
    ];
  }
}
