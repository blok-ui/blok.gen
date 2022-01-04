package example.route;

import blok.context.Context;
import blok.gen2.routing.Route;
import example.data.BlogPost;

#if blok.platform.static
  import example.datasource.BlogPostDataSource;
#end

using Reflect;

typedef PostWithSiblings = {
  public final prev:Null<BlogPost>;
  public final next:Null<BlogPost>;
  public final current:BlogPost;
}

typedef PostRoute = Route<'/post/{id:String}', PostWithSiblings>;

function create(renderer) {
  return new PostRoute({
    #if blok.platform.static
      load: (context:Context, id:String) -> BlogPostDataSource
        .from(context)
        .getPost(id),
    #end
    decode: (context, data:Dynamic) -> {
      var meta:{ next:Dynamic, prev:Dynamic } = data.field('meta');
      return {
        next: if (meta.next != null) BlogPost.fromJson(meta.next) else null,
        prev: if (meta.prev != null) BlogPost.fromJson(meta.prev) else null,
        current: BlogPost.fromJson(data.field('data'))
      }
    },
    render: renderer
  });
}
