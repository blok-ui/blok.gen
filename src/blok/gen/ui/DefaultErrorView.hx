package blok.gen.ui;

class DefaultErrorView extends Component {
  @prop var message:String;

  function render() {
    return Html.text('ERROR: $message');
  }
}
