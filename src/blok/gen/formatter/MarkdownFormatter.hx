package blok.gen.formatter;

import blok.context.Context;
import blok.gen.source.FileResult;

using Markdown;
using StringTools;
using tink.CoreApi;

typedef MarkdownResult<T> = {
  data:T,
  excerpt:String,
  content:String
};

class MarkdownFormatter<T> implements Formatter<MarkdownResult<T>> {
  final formatter:Formatter<T>;
  final sep:String = '---';

  public function new(?formatter) {
    this.formatter = if (formatter == null) new TomlFormatter() else formatter;
  }

  public function parse(context:Context, file:FileResult):Promise<MarkdownResult<T>> {
    var data = file.content;
    if (data.startsWith(sep)) {
      var raw = data.substr(sep.length);
      var index = raw.indexOf(sep);
      var matter = raw.substring(0, index);
      var content = raw.substring(index + sep.length);
      var excerpt = if (content.length > 200) 
        content.substring(0, 200) + '...'
      else
        content;
      
      return formatter.parse(context, {
        meta: file.meta,
        content: matter
      }).next(data -> {
        data: data,
        excerpt: excerpt.markdownToHtml(),
        content: content.markdownToHtml()
      });
    }
    
    return new Error(500, 'Could not parse data');
  }
}
