package blok.gen2.source;

import blok.gen2.formatter.FormatterCollection;
import blok.gen2.formatter.MarkdownFormatter;
import blok.gen2.formatter.TomlFormatter;

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

  public function list<T:{}>(path:String, filter):Promise<Array<FormattedFileResult<T>>> {
    return source
      .list(path, filter)
      .next(files -> Promise.inParallel([ 
        for (file in files) parse(file)
      ]));
  }

  public function get<T:{}>(path:String):Promise<FormattedFileResult<T>> {
    return source.get(path).next(parse);
  }

  function parse<T:{}>(file:FileResult):Promise<FormattedFileResult<T>> {
    return switch formatters.find(file.meta.extension) {
      case null: Promise.reject(new Error(404, 'No formatter exists for the extension ${file.meta.extension}'));
      case formatter:
        formatter
          .parse(file)
          .next(data -> Promise.resolve({
            meta: file.meta,
            content: file.content,
            formatted: data
          }));
    };
  }
}
