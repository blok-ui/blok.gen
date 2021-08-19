package blok.gen;

using StringTools;

@service(fallback = new MetadataService(new Config({
  siteTitle: 'Unnamed',
  siteUrl: '',
  apiRoot: 'api'
})))
class MetadataService implements Service {
  var config:Config;
  var site:SiteMetadata;
  var page:PageMetadata = new PageMetadata({ title: '' });

  public function new(config) {
    this.config = config;
    site = new SiteMetadata({
      title: config.siteTitle,
      url: config.siteUrl
    });
  }

  public function getSite() {
    return site;
  }

  public function getPage() {
    return page;
  }

  public function setPageTitle(title:String) {
    page = page.withTitle(title.htmlEscape());
  }

  // etc
}
