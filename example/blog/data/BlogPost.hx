package blog.data;

import blok.gen.storage.FileResult;
import blok.gen.data.Model;
import blok.gen.data.Id;
import blok.gen.data.Content;

using Reflect;
using tink.CoreApi;

@model(name = 'post')
class BlogPost implements Model {
  #if blok.gen.ssr
    public static function parse(file:FileResult, data:Dynamic):Promise<{}> {
      return Promise.resolve(new BlogPost({
        id: file.meta.name,
        title: data.field('data').field('title'),
        content: (data.field('content'):String)
      }).toJson());
    }
  #end

  @constant var id:Id<BlogPost>;
  @prop var title:String;
  @prop var content:Content;
}
