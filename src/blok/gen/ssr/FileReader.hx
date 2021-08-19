package blok.gen.ssr;

import sys.io.File;
import sys.FileSystem;
import blok.gen.storage.FileResult;
import blok.gen.storage.Reader;

using Lambda;
using haxe.io.Path;
using tink.CoreApi;

class FileReader implements Reader {
  final root:String;

  public function new(root) {
    this.root = root;
  }

  public function list(path:String, filter:(name:String)->Bool):Promise<Array<FileResult>> {
    var fullPath = Path.join([ root, path ]);
    if (!FileSystem.exists(fullPath) || !FileSystem.isDirectory(fullPath)) {
      return new Error(404, '${fullPath} is not a directory');
    }
    var paths = FileSystem.readDirectory(fullPath).filter(filter);
    return Promise.inParallel([ 
      for (file in paths) read(Path.join([ path, file ]))
    ]);
  }

  public function read(path:String):Promise<FileResult> {
    var fullPath = Path.join([ root, path ]);
    var dir = fullPath.directory();

    if (!FileSystem.isDirectory(dir)) {
      return new Error(404, '${dir} is not a directory');
    }

    if (!FileSystem.exists(fullPath) || FileSystem.isDirectory(fullPath)) {
      return new Error(404, 'File ${fullPath} does not exist');
    } 
    
    var stat = FileSystem.stat(fullPath);
    var content = File.getContent(fullPath);
    return ({
      meta: {
        path: fullPath,
        name: fullPath.withoutDirectory().withoutExtension(),
        extension: fullPath.extension(),
        created: stat.ctime,
        updated: stat.mtime
      },
      content: content
    }:FileResult);
  }
}
