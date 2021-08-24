package blok.gen.ssr.formatter;

import blok.gen.datasource.FileResult;
import toml.TomlError;

using tink.CoreApi;

class TomlFormatter<T> implements Formatter<T> {
  public function new() {}

  public function parse(file:FileResult):Promise<T> {
    return new Promise((res, rej) -> {
      try {
        res(Toml.parse(file.content));
      } catch (e:TomlError) {
        rej(new Error(500, e.toString()));
      } catch (e) {
        rej(new Error(500, e.message));
      }
      () -> null;
    });
  }
}