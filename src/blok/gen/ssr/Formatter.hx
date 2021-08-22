package blok.gen.ssr;

import blok.gen.storage.FileResult;

using tink.CoreApi;

interface Formatter<T> {
  public function parse(file:FileResult):Promise<T>;
}
