package blok.gen.content;

import blok.data.Record;

class Content implements Record {
  @prop var type:String;
  @prop var data:Dynamic;
  @prop var children:Array<Content> = [];
}
