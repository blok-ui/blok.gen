package example.route;

import blok.gen2.routing.Route;
import example.data.BlogPost;

using Reflect;
using blok.gen2.data.PaginationTools;

typedef PostArchiveWithPagination = {
  public final page:Int;
  public final totalPosts:Int;
  public final totalPages:Int;
  public final posts:Array<BlogPost>;
}

typedef PostArchiveRoute = Route<'/post-archive/page-{page:Int}', PostArchiveWithPagination>;

function decode(data:Dynamic, perPage:Int):PostArchiveWithPagination {
  var meta:{ startIndex:Int, total:Int } = data.field('meta');
  return {
    page: meta.startIndex.toPageNumber(perPage),
    totalPosts: meta.total,
    totalPages: meta.total.paginate(perPage),
    posts: (data.field('data'):Array<Dynamic>).map(BlogPost.fromJson)
  };
}
