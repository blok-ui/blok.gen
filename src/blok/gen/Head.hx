package blok.gen;

class Head extends Component {
  @prop var siteTitle:String;
  @prop var pageTitle:String;
  #if blok.platform.static 
    @use var metadata:blok.gen.ssr.MetadataService;
  #end

  // Todo: assets and stuff too

  @before
  function setDocumentTitle() {
    var title = [ siteTitle, pageTitle ].filter(t -> t != null).join(' | ');
    #if blok.platform.dom
      DomTools.setTitle(title);
    #else
      metadata.setTitle(title);
    #end
  }

  function render() {
    return null;
  }
}
