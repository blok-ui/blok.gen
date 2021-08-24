package blog.data;

import blok.Record;
import blok.gen.data.Id;
import blok.gen.data.Content;

using Reflect;
using tink.CoreApi;

class BlogPost implements Record {
  @constant var id:Id<BlogPost>;
  @prop var title:String;
  @prop var content:Content;
}
