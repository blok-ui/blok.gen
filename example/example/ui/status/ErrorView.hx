package example.ui.status;

import example.ui.layout.DefaultLayout;

using Blok;

class ErrorView extends Component {
  @prop var message:String;

  function render() {
    return DefaultLayout.node({
      pageTitle: 'Error',
      children: [
        Html.text(message)
      ]
    });
  }
}
