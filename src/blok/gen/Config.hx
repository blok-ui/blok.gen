package blok.gen;

using haxe.io.Path;

enum AssetType {
  AssetCss(path:String);
}

class Config implements Record {
  @prop var siteTitle:String;
  @prop var siteUrl:String;
  @prop var globalAssets:Array<AssetType> = [];

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
