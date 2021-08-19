package blok.gen.tools;

class PathTools {
  public static function nameToPath(name:String) {
    var path = '';
    for (i in 0...name.length) {
      var c = name.charAt(i);
      path += isUc(c) && i > 0 ? '/' + c.toLowerCase() : c.toLowerCase();
    }
    return path;
  }

  static inline function isUc(c:String) {
    return c > 'A' && c < 'Z';
  }
}
