package example.route;

import blok.data.Record;
import blok.gen2.routing.Route;
import example.data.BlogPost;
import example.data.BlogConfig;

#if blok.platform.static
  import example.datasource.BlogPostDataSource;
#end

using Reflect;
using blok.gen2.data.PaginationTools;

class PostArchiveWithPagination implements Record {
  @prop var page:Int;
  @prop var totalPosts:Int;
  @prop var totalPages:Int;
  @prop var posts:Array<BlogPost>;
}

typedef PostArchiveRoute = Route<'/post-archive/page-{page:Int}', PostArchiveWithPagination>;

function create(renderer) {
  return new PostArchiveRoute({
    #if blok.platform.static
      load: (context, page:Int) -> {
        var perPage = BlogConfig.from(context).perPage;
        return BlogPostDataSource
          .from(context)
          .findPosts(page.toIndex(perPage), perPage);
      },
    #end
    decode: (context, data:Dynamic) -> {
      var perPage = BlogConfig.from(context).perPage;
      var meta:{ startIndex:Int, total:Int } = data.field('meta');
      return PostArchiveWithPagination.fromJson({
        page: meta.startIndex.toPageNumber(perPage),
        totalPosts: meta.total,
        totalPages: meta.total.paginate(perPage),
        posts: data.field('data')
      });
    },
    render: renderer
  });
}
