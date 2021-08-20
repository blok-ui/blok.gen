import blok.gen.ssr.formatter.TomlFormatter;
import blok.gen.ssr.formatter.MarkdownFormatter;
import blok.gen.ssr.FormatterCollection;
import blok.gen.ssr.FileReader;
import blok.gen.ssr.SsrKernal;
import blog.Blog.config;
import blog.Blog.factory;

using haxe.io.Path;

function main() {
  var root = Sys.programPath().directory().directory();
  var kernal = new SsrKernal(
    Path.join([ root, 'dist', 'www' ]),
    config,
    factory,
    new FileReader(Path.join([ root, 'example', 'data' ])),
    new FormatterCollection([
      'md' => new MarkdownFormatter(new TomlFormatter())
    ])
  );
  kernal.run();
}
