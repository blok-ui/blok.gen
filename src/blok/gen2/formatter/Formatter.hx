package blok.gen2.formatter;

import blok.context.Context;
import blok.gen2.source.FileResult;

using tink.CoreApi;

interface Formatter<T> {
  public function parse(context:Context, file:FileResult):Promise<T>;
}
