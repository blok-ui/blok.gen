package blok.gen.datasource;

import image.Image;

using Lambda;
using tink.CoreApi;
using haxe.io.Path;
using sys.io.File;
using sys.FileSystem;

enum ImageSize {
  Full;
  Medium;
  Thumbnail;
  Custom(x:Int, y:Int);
}

typedef ImageEntry = {
  name:String,
  source:String,
  size:ImageSize
}

class ImageDataSourceConfig implements Record {
  @prop var mediumSize:Int = 900;
  @prop var thumbSize:Int = 200;
  @prop var source:String;
  @prop var destination:String;
}

@service(fallback = new ImageDataSource({
  source: Config.from(context).ssr.source,
  destination: Config.from(context).ssr.destination
}))
class ImageDataSource implements Service {
  final config:ImageDataSourceConfig;

  public function new(props) {
    config = new ImageDataSourceConfig(props);
  }

  public function list(path:String):Promise<Array<String>> {
    var src = Path.join([ config.source, path ]);
    if (!FileSystem.exists(src)) return Promise.reject(new Error(404, 'Folder does not exist'));
    return Promise.resolve(FileSystem.readDirectory(src).filter(isVaildExtendion));
  }

  public function fetch(entries:Array<ImageEntry>):Promise<Array<ImageInfo>> {
    return Promise.inParallel([ for (e in entries) process(e) ]);
  }
  
  function isVaildExtendion(src:String) {
    return [ 'jpg', 'png' ].contains(src.extension());
  }

  function process(entry:ImageEntry):Promise<ImageInfo> {
    var src = Path.join([ 
      config.source, 
      entry.source 
    ]);
    var dest = Path.join([ 
      config.destination,
      entry.name
    ]);
    var dir = dest.directory();

    if (!src.exists()) {
      return new Error(404, 'No image exists at ${src}');
    }

    if (dest.exists()) {
      var destAge = dest.stat().mtime.getTime();
      var srcAge = src.stat().mtime.getTime();
      if (srcAge <= destAge) return if (isVaildExtendion(src)) 
        Image.getInfo(src);
      else
        return Promise.resolve(({
          width: 0,
          height: 0,
          format: 'unknown'
        }:ImageInfo));
    }

    if (!dir.isDirectory()) {
      if (dir.exists()) return new Error(500, '${dir} is not a directory');
      dir.createDirectory();
    }

    if (!isVaildExtendion(src)) {
      src.copy(dest);
      return Promise.resolve(({
        width: 0,
        height: 0,
        format: 'unknown'
      }:ImageInfo));
    }

    return Image.getInfo(src).next(info -> switch entry.size {
      case Full: 
        src.copy(dest);
        info;
      case Medium: 
        Image.resize(
          src,
          dest,
          {
            engine: Vips,
            width: info.width > config.mediumSize
              ? info.width
              : config.mediumSize,
            height: info.height > config.mediumSize
              ? info.height
              : config.mediumSize
          }
        ).next(_ -> info);
      case Thumbnail:
        Image.resize(
          src,
          dest,
          {
            engine: Vips,
            width: config.thumbSize,
            height: config.thumbSize
          }
        ).next(_ -> info);
      case Custom(x, y):
        Image.resize(
          src,
          dest,
          {
            engine: Vips,
            width: x,
            height: y
          }
        ).next(_ -> info);
    });
  }
}
