package blok.gen.ssr;

import blok.gen.storage.Writer;

using sys.io.File;
using sys.FileSystem;
using haxe.io.Path;
using tink.CoreApi;

class FileWriter implements Writer {
  final root:String;

  public function new(root) {
    this.root = root;
  }
  
  public function write(path:String, content:String):Promise<Noise> {
    var path = Path.join([ root, path ]);
    var dir = path.directory();
    if (!dir.isDirectory()) {
      if (dir.exists()) {
        return new Error(500, 'Cannot write to the directory ${dir} as it is an existing file');
      }
      try {
        dir.createDirectory();
      } catch (e) {
        return new Error(500, 'Unable to create the directory ${dir}: ${e.message}');
      }
    }
    try {
      path.saveContent(content);
    } catch (e) {
      return new Error(500, 'Unable to save the file ${dir}: ${e.message}');
    }
    return Noise;
  }
}
