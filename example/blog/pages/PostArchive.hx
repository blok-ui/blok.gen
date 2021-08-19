package blog.pages;

import blok.gen.MetadataService;
import blok.gen.Page;
import blok.gen.PageLink;
import blok.gen.data.StoreResult;
import blog.data.BlogPost;

using Blok;
using blok.gen.tools.PaginationTools;

@page(route = 'post-archive')
class PostArchive extends Page<StoreResult<BlogPost>> {
  static final perPage:Int = 2;

  public function load(pageNum:String) {
    var page = Std.parseInt(pageNum);
    var first = page.toIndex(perPage);
    return BlogPost
      .fromStore(store)
      .find({ first: first, count: perPage });
  }

  public function render(meta:MetadataService, posts:StoreResult<BlogPost>) {
    var totalPages = posts.meta.total.paginate(perPage);
    var currentPage = posts.meta.startIndex.toPageNumber(perPage);
    var nextPage = currentPage + 1;

    meta.setPageTitle('Post Archives | Page ${currentPage} of ${totalPages}');
    
    return Html.div({},
      Html.ul({}, ...[ for (post in posts.data) 
        Html.li({},
          PageLink.node({
            url: '/post/${post.id}',
            child: Html.text(post.title)
          })
        )
      ]),
      if (nextPage <= totalPages)
        PageLink.node({
          url: '/post-archive/${nextPage}',
          child: Html.text('Next Page ->')
        })
      else null
    );
  }
}
