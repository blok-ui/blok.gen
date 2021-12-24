package blok.gen2.formatter;

import blok.gen2.source.FileResult;

using tink.CoreApi;

interface Formatter<T> {
  public function parse(file:FileResult):Promise<T>;
}
