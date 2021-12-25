package blok.gen;

import tink.core.Error;

@service(fallback = throw 'No config found: make sure Config is registered first.')
class Config implements Service implements Record {
  @prop var site:SiteConfig;
  @prop var view:ViewConfig;

  #if blok.platform.static
    @prop var ssr:SsrConfig;
  #end
}

class SiteConfig implements Record {
  @prop var url:String;
  @prop var title:String;
  @prop var appName:String = 'app';
  @prop var rootId:String = 'root';
  @prop var assetPath:String = '/assets';
  @prop var assets:AssetCollection;
}

class ViewConfig implements Record {
  @prop var error:(e:Error)->VNode;
  @prop var loading:()->VNode;
}

#if blok.platform.static
  class SsrConfig implements Record {
    @prop var source:String;
    @prop var destination:String;
  }
#end
