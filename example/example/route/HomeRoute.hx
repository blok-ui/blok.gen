package example.route;

import blok.context.Context;
import blok.gen2.routing.Route;
import blok.gen2.routing.Matchable;
import example.data.BlogPost;
import example.data.BlogConfig;

#if blok.platform.static
  import example.datasource.BlogPostDataSource;
#end

using Reflect;

typedef HomeRoute = Route<'/', Array<BlogPost>>; 

function create(renderer):Matchable {
  return new HomeRoute({
    #if blok.platform.static
      load: (context:Context) -> BlogPostDataSource
        .from(context)
        .findPosts(0, BlogConfig.from(context).perPage),
    #end
    decode: (context:Context, data:Dynamic) -> 
      (data.field('data'):Array<Dynamic>).map(BlogPost.fromJson),
    render: renderer
  });
}
