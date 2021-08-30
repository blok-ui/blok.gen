package blok.gen;

import blok.gen.ConfigService;

@service(fallback = new MetadataService(ConfigService.from(context).getConfig()))
class MetadataService implements Service {
  public final config:Config;
  var pageTitle:String = null;

  public function new(config) {
    this.config = config;
    pageTitle = config.site.siteTitle;
  }

  public function setPageTitle(title:String) {
    pageTitle = '${config.site.siteTitle} | $title';
    #if blok.platform.dom
      blok.gen.tools.DomTools.setTitle(pageTitle);
    #end
  }

  public function getPageTitle() {
    return pageTitle;
  }
}
