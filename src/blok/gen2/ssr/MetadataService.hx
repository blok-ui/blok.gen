package blok.gen2.ssr;

@service(fallback = new MetadataService())
class MetadataService implements Service {
  public var title:String = '';

  public function new() {}

  public function setTitle(title) {
    this.title = title;
  }
}
