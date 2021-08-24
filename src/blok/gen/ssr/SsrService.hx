package blok.gen.ssr;

@service(fallback = new SsrService())
class SsrService implements Service {
  var data:Dynamic = {};

  public function new() {}

  public function setData(data:Dynamic) {
    this.data = data;
  }

  public function getData():{} {
    return data;
  }
}
