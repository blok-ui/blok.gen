package blok.gen.source;

typedef FileResult = {
  public final meta:{
    path:String,
    name:String,
    extension:String,
    created:Date,
    updated:Date
  };
  public final content:String;
}
