package blok.gen;

class PageLink extends Component {
  @prop var url:String;
  @prop var child:VNode;
  @use var router:PageRouter;
  #if blok.gen.ssr
    @use var visitor:blok.gen.ssr.Visitor;
  #end
  
  #if blok.gen.ssr
    @before
    function visit() {
      visitor.visit(url);
    }
  #end

  function render() {
    return Html.a({
      href: url,
      onclick: e -> {
        e.preventDefault();
        router.setUrl(url);
      }
    }, child);
  }
}
