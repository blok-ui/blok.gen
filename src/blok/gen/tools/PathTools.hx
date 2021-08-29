package blok.gen.tools;

using StringTools;
using haxe.io.Path;

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

  public static inline function prepareUrl(url:String) {
    var normalized = url.normalize();
    if (normalized.startsWith('/')) normalized = normalized.substr(1);
    return normalized;
  }
}
