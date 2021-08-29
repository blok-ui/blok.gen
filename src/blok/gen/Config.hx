package blok.gen;

class Config implements Record {
  @prop var site:SiteConfig;

  #if blok.gen.ssr
    @prop var ssrConfig:SsrConfig;
  #end

  public function asService() {
    return new ConfigService(this);
  }
}

class SiteConfig implements Record {
  @prop var url:String;
  @prop var siteTitle:String;
  @prop var siteUrl:String;
  @prop var rootId:String = 'root';
  @prop var assetPath:String = '/assets';
  // @prop var globalAssets:Array<AssetType> = [];
}

#if blok.gen.ssr
  class SsrConfig implements Record {
    @prop var source:String;
    @prop var destination:String;
  }
#end
