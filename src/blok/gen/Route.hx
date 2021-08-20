package blok.gen;

using tink.CoreApi;

class Route<T> {
  public final match:(url:String)->Option<T>;
  
  public function new(match) {
    this.match = match;
  }
}
