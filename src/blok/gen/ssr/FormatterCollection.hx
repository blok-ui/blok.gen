package blok.gen.ssr;

abstract FormatterCollection(Map<String, Formatter<Dynamic>>) {
  public function new(formatters) {
    this = formatters;
  }

  public function find(type:String) {
    return this.get(type);
  }
}