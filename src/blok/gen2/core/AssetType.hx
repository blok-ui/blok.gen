package blok.gen2.core;

enum AssetType {
  AssetCss(path:String, local:Bool);
  AssetJs(path:String, local:Bool);
  AssetPreload(path:String, local:Bool);
}
