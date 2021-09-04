package blok.gen.datasource;

import blok.gen.data.Content;
import sys.io.File;
import sys.FileSystem;

using Lambda;
using haxe.io.Path;
using tink.CoreApi;

// @todo: It might be a lot simpler to return Promises from this DataSource
//        rather than AsyncData.
//
//        In general, I think we need to take another look at AsyncData --
//        it really only is needed when hydrating an app.
class FileDataSource implements DataSource {
  final root:String;
  final cache:Map<String, Dynamic> = [];

  public function new(root) {
    this.root = root;
  }
  
  public function listFolders(path:String):AsyncData<Array<String>> {
    var fullPath = Path.join([ root, path ]);

    if (!FileSystem.exists(fullPath) || !FileSystem.isDirectory(fullPath)) {
      return Failed(new Error(404, '${fullPath} is not a directory'));
    }
    
    return Ready(FileSystem
      .readDirectory(fullPath)
      .filter(p -> FileSystem.isDirectory(Path.join([ fullPath, p ]))));
  }

  public function list(path:String, filter:(name:String)->Bool):AsyncData<Array<FileResult>> {
    if (cache.exists(path)) {
      return Ready(cache.get(path));
    }

    var fullPath = Path.join([ root, path ]);

    if (!FileSystem.exists(fullPath) || !FileSystem.isDirectory(fullPath)) {
      return Failed(new Error(404, '${fullPath} is not a directory'));
    }

    var paths = FileSystem.readDirectory(fullPath).filter(filter);
   
    return Loading(Promise.inParallel([ 
      for (file in paths) read(Path.join([ path, file ]))
    ]).next(files -> {
      cache.set(fullPath, files);
      files;
    }));
  }

  public function get(path:String):AsyncData<FileResult> {
    if (cache.exists(path)) {
      return Ready(cache.get(path));
    }

    return Loading(read(path).next(file -> {
      cache.set(path, file);
      file;
    }));
  }

  function read(path:String):Promise<FileResult> {
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