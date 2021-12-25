package blok.gen2.cache;

interface Cache<T> {
  public function hit(key:String):Bool;
  public function get(key:String):T;
  public function set(key:String, value:T, ?lifetime:Float):Void;
  public function remove(key:String):Void;
  public function clear():Void;
}
