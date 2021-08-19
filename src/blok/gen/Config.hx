package blok.gen;

using haxe.io.Path;

class Config implements Record {
  @prop var siteTitle:String;

  /**
    The name of the cilent app.
  **/
  @prop var appName:String = 'app';

  /** 
    Root for the API.
  **/ 
  @prop var apiRoot:String;

  /**
    The id of the root element.
  **/
  @prop var rootId:String = 'root';

  /**
    Where to find assets (such as scripts and styles)
  **/
  @prop var assetPath:String = '/assets';

  
  public function getClientAppPath() {
    return Path
      .join([ assetPath, appName ])
      .withExtension('js');
  }
}
