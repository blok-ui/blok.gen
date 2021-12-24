package example.data;

import blok.Record;
import blok.gen2.data.Id;
import blok.gen2.content.Content;

using Reflect;
using tink.CoreApi;

class BlogPost implements Record {
  @constant var id:Id<BlogPost>;
  @prop var title:String;
  @prop var content:Array<Content>;
}
