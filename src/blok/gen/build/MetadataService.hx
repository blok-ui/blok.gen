package blok.gen.build;

import blok.context.Service;

@service(fallback = new MetadataService())
class MetadataService implements Service {
  public var title:String = '';

  public function new() {}

  public function setTitle(title) {
    this.title = title;
  }
}
