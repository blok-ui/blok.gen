package blok.gen2.ui;

import blok.gen2.routing.Router;
import blok.gen2.core.Config;

using haxe.io.Path;

class PageLink extends Component {
  @prop var className:Null<String> = null;
  @prop var url:String;
  @prop var children:Array<VNode>;
  @use var router:Router;
  @use var config:Config;
  #if blok.platform.static
    @use var visitor:blok.gen2.ssr.Visitor;
  #end
  
  #if blok.platform.static
    @before
    function visit() {
      visitor.visit(url);
    }
  #end

  function render() {
    return Html.a({
      className: className,
      href: Path.join([ config.site.url, url  ]),
      onclick: e -> {
        e.preventDefault();
        router.setUrl(Path.join([ config.site.url, url ]));
      }
    }, ...children);
  }
}
