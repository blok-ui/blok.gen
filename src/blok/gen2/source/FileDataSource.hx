package blok.gen2.source;

import sys.io.File;
import sys.FileSystem;
import blok.context.Service;
import blok.gen2.core.Config;

using Lambda;
using haxe.io.Path;
using tink.CoreApi;

@service(fallback = new FileDataSource())
class FileDataSource implements Service {
  @use var config:Config;

  final cache:Map<String, Dynamic> = [];

  public function new() {}
  
  public function listFolders(path:String):Promise<Array<String>> {
    var fullPath = Path.join([ config.ssr.source, path ]);

    if (!FileSystem.exists(fullPath) || !FileSystem.isDirectory(fullPath)) {
      return Promise.reject(new Error(404, '${fullPath} is not a directory'));
    }
    
    return Promise.resolve(FileSystem
      .readDirectory(fullPath)
      .filter(p -> FileSystem.isDirectory(Path.join([ fullPath, p ]))));
  }

  public function list(path:String, filter:(name:String)->Bool):Promise<Array<FileResult>> {
    if (cache.exists(path)) {
      return Promise.resolve(cast cache.get(path));
    }

    var fullPath = Path.join([ config.ssr.source, path ]);

    if (!FileSystem.exists(fullPath) || !FileSystem.isDirectory(fullPath)) {
      return Promise.reject(new Error(404, '${fullPath} is not a directory'));
    }

    var paths = FileSystem.readDirectory(fullPath).filter(filter);
   
    return Promise.inParallel([ 
      for (file in paths) read(Path.join([ path, file ]))
    ]).next(files -> {
      cache.set(fullPath, files);
      files;
    });
  }

  public function get(path:String):Promise<FileResult> {
    if (cache.exists(path)) {
      return Promise.resolve(cast cache.get(path));
    }

    return read(path).next(file -> {
      cache.set(path, file);
      file;
    });
  }

  function read(path:String):Promise<FileResult> {
    var fullPath = Path.join([ config.ssr.source, path ]);
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
