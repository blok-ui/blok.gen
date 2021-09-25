package example.data;

using Blok;

@service(fallback = new BlogConfig({ perPage: 12 }))
class BlogConfig implements Record implements Service {
  @prop var perPage:Int;
}
