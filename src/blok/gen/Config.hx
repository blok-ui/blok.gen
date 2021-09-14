package blok.gen;

@service(fallback = throw 'No config found')
class Config implements Service implements Record {
  @prop var site:SiteConfig;
  @prop var hooks:SiteHooks;

  #if blok.platform.static
    @prop var ssr:SsrConfig;
  #end
}

class SiteHooks implements Record {
  /**
    This runs when a page or route STARTS loading.
  **/
  @prop var onMatched:(result:LoadingResult<PageResult>)->Void = null;

  /** 
    This runs when a page has FINISHED loading.
  **/
  @prop var onPageLoaded:()->Void = null;
}

class SiteConfig implements Record {
  @prop var url:String;
  @prop var title:String;
  @prop var rootId:String = 'root';
  @prop var assetPath:String = '/assets';
  // @prop var assets:AssetCollection = new AssetCollection([]);
  // @prop var loadingView:(props:{}, ?key:Key)->VNode;
  // @prop var errorView:(props:{ message:String }, ?key:Key)->VNode;
}

#if blok.platform.static
  class SsrConfig implements Record {
    @prop var source:String;
    @prop var destination:String;
  }
#end
