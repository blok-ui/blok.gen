package blok.gen.storage;

typedef FileResult = {
  meta:{
    path:String,
    name:String,
    extension:String,
    created:Date,
    updated:Date
  },
  content:String
}
