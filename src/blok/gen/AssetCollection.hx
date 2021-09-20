package blok.gen;

@:forward(iterator, copy)
abstract AssetCollection(Array<AssetType>) from Array<AssetType> {
  public function new(assets) {
    this = assets;
  }

  public function addLocalCss(path:String) {
    this.push(AssetCss(path, true));
  }

  public function addExternalCss(path:String) {
    this.push(AssetCss(path, false));
  }

  public function addLocalJs(path:String) {
    this.push(AssetJs(path, true));
  }

  public function addExternalJs(path:String) {
    this.push(AssetJs(path, false));
  }
  
  public function addLocalPreload(path:String) {
    this.push(AssetPreload(path, true));
  }

  public function addExternalPreload(path:String) {
    this.push(AssetPreload(path, false));
  }
}
