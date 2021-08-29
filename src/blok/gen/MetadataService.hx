package blok.gen;

import blok.gen.ConfigService;

@service(fallback = new MetadataService(ConfigService.from(context).getConfig()))
class MetadataService implements Service {
  public final config:Config;

  public function new(config) {
    this.config = config;
  }

  public function setPageTitle(title:String) {
    
  }
}
