package example.data;

import blok.gen.data.Id;
import blok.gen.content.Content;

using Blok;
using Reflect;
using tink.CoreApi;

class BlogPost implements Record {
  @constant var id:Id<BlogPost>;
  @prop var title:String;
  @prop var content:Array<Content>;
}
