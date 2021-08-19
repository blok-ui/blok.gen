package blok.gen.ssr;

using tink.CoreApi;

interface Formatter<T> {
  public function parse(contents:String):Promise<T>;
}
