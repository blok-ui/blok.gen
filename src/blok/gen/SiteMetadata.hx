package blok.gen;

class SiteMetadata implements Record {
  @prop var title:String;
  @prop var url:String;
  @prop var siteData:Array<Dynamic> = [];
}
