package blok.gen.formatter;

import blok.context.Context;
import blok.gen.source.FileResult;

using tink.CoreApi;

interface Formatter<T> {
  public function parse(context:Context, file:FileResult):Promise<T>;
}
