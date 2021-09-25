package blok.gen;

@service(fallback = new MetadataService())
class MetadataService implements Service {
  @use var config:Config;
  var pageTitle:String = null;

  public function new() {}

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
