import blok.gen.ssr.formatter.TomlFormatter;
import blok.gen.ssr.formatter.MarkdownFormatter;
import blok.gen.ssr.FormatterCollection;
import blok.gen.ssr.SsrKernal;
import blok.gen.ssr.SsrConfig;
import blog.Blog.config;
import blog.Blog.routes;

using haxe.io.Path;

function main() {
  var root = Sys.programPath().directory().directory();
  var kernal = new SsrKernal(
    new SsrConfig({
      source: Path.join([ root, 'example', 'data' ]),
      destination: Path.join([ root, 'dist', 'www' ])
    }),
    config,
    routes,
    new FormatterCollection([
      'md' => new MarkdownFormatter(new TomlFormatter())
    ])
  );
  kernal.run();
}
