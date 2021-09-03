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

// @todo: make more configurable
class ImageDataSource {
  static final mediumSize = 900;
  static final thumbSize = 200;

  final destRoot:String;
  final sourceRoot:String;

  public function new(destRoot, sourceRoot) {
    this.destRoot = destRoot;
    this.sourceRoot = sourceRoot;
  }

  public function fetch(entries:Array<ImageEntry>):AsyncData<Array<ImageInfo>> {
    return Loading(Promise.inParallel([ for (e in entries) process(e) ]));
  }

  function process(entry:ImageEntry):Promise<ImageInfo> {
    var src = Path.join([ 
      sourceRoot, 
      entry.source 
    ]);
    var dest = Path.join([ 
      destRoot,
      entry.name
    ]);
    var dir = dest.directory();

    function isVaildExtendion() {
      return [ 'jpg', 'png' ].contains(src.extension());
    }

    if (!src.exists()) {
      return new Error(404, 'No image exists at ${src}');
    }

    if (dest.exists()) {
      var destAge = dest.stat().mtime.getTime();
      var srcAge = src.stat().mtime.getTime();
      if (srcAge <= destAge) return if (isVaildExtendion()) 
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

    if (!isVaildExtendion()) {
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
            width: info.width > mediumSize
              ? info.width
              : mediumSize,
            height: info.height > mediumSize
              ? info.height
              : mediumSize
          }
        ).next(_ -> info);
      case Thumbnail:
        Image.resize(
          src,
          dest,
          {
            engine: Vips,
            width: thumbSize,
            height: thumbSize
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
