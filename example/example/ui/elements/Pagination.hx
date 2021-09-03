package example.ui.elements;

using Nuke;
using Blok;

class Pagination {
  public static function container(...children:VNode) {
    return Html.nav({}, 
      Html.ul({ className: 'pagination' }, ...children)
    );
  }

  public static function item(props:{ ?isDisabled:Bool, ?isActive:Bool }, ...children:VNode) {
    return Html.li({ 
      className: ClassName.ofMap([
        'page-item' => true,
        'active' => props.isActive == true,
        'disabled' => props.isDisabled == true
      ]) 
    }, ...children);
  }
}
