package example.ui.elements;

using Blok;

class Container {
  public static function main(...children:VNode) {
    return Html.main({}, ...children);
  }

  public static function header(props:{ title:String }) {
    return Html.header({}, 
      Html.h2({}, Html.text(props.title))
    );
  }

  public static function section(...children:VNode) {
    return Html.section({ className: 'container' }, ...children);
  }

  public static function row(...children:VNode) {
    return Html.div({ className: 'row gy-2' }, ...children);
  }

  public static function column(props:{ ?span:Int }, ...children:VNode) {
    return Html.div({ 
      className: props.span == null ? 'col' : 'col-${props.span}' 
    }, ...children);
  }
}
