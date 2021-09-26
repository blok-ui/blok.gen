package blok.gen.data;

import blok.Html;
import blok.VElement;

@service(fallback = ContentRenderer.withDefaults())
class ContentRenderer implements Service {
  public static function withDefaults() {
    return new ContentRenderer([
      '@html' => (renderer, content) -> {
        VElement.create(Reflect.field(content.data, 'tag'), { 
          attrs: Reflect.field(content.data, 'props'),
          children: renderer.render(content.children)
        });
      },
      '@italic' => (renderer, content) -> Html.i({}, ...renderer.render(content.children)),
      '@bold' => (renderer, content) -> Html.b({}, ...renderer.render(content.children)),
      '@text' => (_, content) -> Html.text(content.data)
    ]);
  }

  public static function renderContent(content:Array<Content>):VNode {
    return ContentRenderer.use(renderer -> Html.fragment(...renderer.render(content)));
  }

  final mappings:Map<String, (renderer:ContentRenderer, content:Content)->VNode>;

  public function new(mappings) {
    this.mappings = mappings;
  }

  public function map(type, render) {
    mappings.set(type, render);
    return this;
  }

  public function render(content:Array<Content>):Array<VNode> {
    return content.map(item -> {
      var render = mappings.get(item.type);
      if (render == null) throw 'No renderer found for ${item.type}';
      render(this, item);
    });
  }
}
