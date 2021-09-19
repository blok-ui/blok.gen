package blok.gen.ssr;

import haxe.ds.ReadOnlyArray;

class HtmlDocument implements Record {
  @prop var title:String;
  @prop var head:ReadOnlyArray<String>;
  @prop var body:ReadOnlyArray<String>;

  public function toHtml() {
    return [
      '<!doctype html>',
      '<html>',
        '<head>',
          '<meta charset="utf-8">',
          '<meta name="viewport" content="width=device-width,initial-scale=1,minimum-scale=1">',
          '<title>$title</title>',
          head.join(''),
        '</head>',
        '<body>${body.join('')}</body>',
      '</html>'
    ].join('');
  }
}
