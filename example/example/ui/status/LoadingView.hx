package example.ui.status;

import example.ui.layout.DefaultLayout;

using Blok;

class LoadingView extends Component {
  function render() {
    return DefaultLayout.node({
      children: [
        Html.div(
          {
            className: 'spinner-border',
            role: 'status'
          },
          Html.span({ className: 'visually-hidden' }, 
            Html.text('Loading...')
          )
        )
      ]
    }); 
  }
}
