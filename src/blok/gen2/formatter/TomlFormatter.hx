package blok.gen2.formatter;

import toml.TomlError;
import blok.gen2.source.FileResult;

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