package blok.gen.cli;

interface Console {
  public function write(content:String):Void;
  public function update(content:String):Void;
  public function clear(replaceWith:String = ''):Void;
  public function hideCursor():Void;
  public function showCursor():Void;
}
