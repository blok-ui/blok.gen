package blok.gen.core;

class DomTools {  
  static inline function getBody() {
    #if blok.platform.dom
      return js.Browser.document.getElementsByTagName('body')[0];
    #else
      throw 'Not available on static platforms';
    #end
  }

  public static function setTitle(title:String) {
    #if blok.platform.dom
      var el = js.Browser.document.head.querySelector('title');
      if (el == null) {
        el = js.Browser.document.createTitleElement();
        js.Browser.document.head.appendChild(el);
      }
      el.innerHTML = title;
    #end
  }

  public static function lock() {
    #if blok.platform.dom
      var body = getBody();
      var beforeWidth = body.offsetWidth;
      body.setAttribute('style', 'overflow:hidden;');
      var afterWidth = body.offsetWidth;
      var offset = afterWidth - beforeWidth;
      if (offset > 0) {
        body.setAttribute('style', 'overflow:hidden;padding-right:${offset}px');
      }
    #end
  }

  public static function unlock() {
    #if blok.platform.dom
      // todo: this needs to be less error prone
      getBody().removeAttribute('style');
    #end
  }
}
