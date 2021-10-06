package example.ui.elements;

using Blok;

class Pagination {
  public static function container(...children:VNode) {
    return Html.nav({}, 
      Html.ul({ className: 'pagination' }, ...children)
    );
  }

  public static function item(props:{ ?isDisabled:Bool, ?isActive:Bool }, ...children:VNode) {
    return Html.li({ 
      className: [
        'page-item',
        props.isActive == true ? 'active' : null,
        props.isDisabled == true ? 'disabled' : null
      ].filter(item -> item != null).join(' ')
    }, ...children);
  }
}
