package blok.gen.datasource.file;

import blok.gen.datasource.FileResult;

using tink.CoreApi;

interface Formatter<T> {
  public function parse(file:FileResult):Promise<T>;
}
