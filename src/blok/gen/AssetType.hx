package blok.gen;

enum AssetType {
  AssetCss(path:String, local:Bool);
  AssetJs(path:String, local:Bool);
  AssetPreload(path:String, local:Bool);
}
