package blok.gen.datasource;

import blok.gen.datasource.file.FormatterCollection;
import blok.gen.datasource.file.MarkdownFormatter;
import blok.gen.datasource.file.TomlFormatter;

using tink.CoreApi;

@service(fallback = new FormattedDataSource([
  'toml' => new TomlFormatter(),
  'md' => new MarkdownFormatter(new TomlFormatter())
]))
class FormattedDataSource implements Service {
  @use var source:FileDataSource;
  final formatters:FormatterCollection;

  public function new(formatters) {
    this.formatters = new FormatterCollection(formatters);
  }

  public inline function listFolders(path) {
    return source.listFolders(path);
  }

  public function list(path:String, filter) {
    return source
      .list(path, filter)
      .flatMap(files -> Loading(Promise.inParallel([ 
        for (file in files) parse(file).toPromise()
      ])));
  }

  public function get(path:String) {
    source.get(path).flatMap(parse);
  }

  function parse(file:FileResult):AsyncData<Dynamic> {
    return switch formatters.find(file.meta.extension) {
      case null: Failed(new Error(404, 'No formatter exists for the extension ${file.meta.extension}'));
      case formatter: Loading({
        file: file,
        parsed: formatter.parse(file)
      });
    };
  }
}