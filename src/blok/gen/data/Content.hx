package blok.gen2.content;

class Content implements Record {
  @prop var type:String;
  @prop var data:Dynamic;
  @prop var children:Array<Content> = [];
}
