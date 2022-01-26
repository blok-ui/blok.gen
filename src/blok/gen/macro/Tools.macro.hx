package blok.gen.macro;

import haxe.macro.Context;

class Tools {
  public static function typeExists(name:String) {
    try {
      return Context.getType(name) != null;
    } catch (e:String) {
      return false;
    }
  }
}
