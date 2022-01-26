package blok.gen.ui;

import blok.ui.Component;

class Head extends Component {
  @prop var siteTitle:String;
  @prop var pageTitle:String;
  #if blok.platform.static 
    @use var metadata:blok.gen.build.MetadataService;
  #end

  // Todo: assets and stuff too

  @before
  function setDocumentTitle() {
    var title = [ siteTitle, pageTitle ].filter(t -> t != null).join(' | ');
    #if blok.platform.dom
      blok.gen.core.DomTools.setTitle(title);
    #else
      metadata.setTitle(title);
    #end
  }

  function render() {
    return null;
  }
}
