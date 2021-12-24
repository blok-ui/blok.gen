package example.data;

using Blok;

@service(fallback = new BlogConfig({ 
  name: "Unnamed",
  perPage: 12 
}))
class BlogConfig implements Record implements Service {
  @prop var name:String;
  @prop var perPage:Int;
}
