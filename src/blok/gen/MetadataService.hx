package blok.gen;

@service(fallback = new MetadataService(Config.from(context)))
class MetadataService implements Service {
  final config:Config;
  var pageTitle:String = null;

  public function new(config) {
    this.config = config;
    pageTitle = config.site.title;
  }

  public function setPageTitle(title:String) {
    pageTitle = '${config.site.title} | $title';
    #if blok.platform.dom
      blok.gen.tools.DomTools.setTitle(pageTitle);
    #end
  }

  public function getPageTitle() {
    return pageTitle;
  }
}
