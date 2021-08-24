package blog.pages;

import blok.gen.MetadataService;
import blok.gen.Page;
import blog.data.BlogPost;

using Blok;
using Reflect;
using tink.CoreApi;
using blok.gen.tools.PaginationTools;

typedef PostsWithMeta = {
  meta:{
    total:Int,
    startIndex:Int
  },
  data:Array<BlogPost>
};

@page(route = 'post-archive')
class PostArchive extends Page<PostsWithMeta> {
  static final perPage:Int = 2;

  public function load(page:Int) {
    return blog.datasource.BlogPostDataSource
      .findPosts(config.ssr, page.toIndex(perPage), perPage);
  }

  public function decode(data:Dynamic):PostsWithMeta {
    return {
      meta: data.field('meta'),
      data: (data.field('data'):Array<Dynamic>).map(BlogPost.new)
    };
  }

  public function render(meta:MetadataService, posts:PostsWithMeta) {
    var totalPages = posts.meta.total.paginate(perPage);
    var currentPage = posts.meta.startIndex.toPageNumber(perPage);
    var nextPage = currentPage + 1;

    meta.setPageTitle('Post Archives | Page ${currentPage} of ${totalPages}');
    
    return Html.div({},
      Html.ul({}, ...[ for (post in posts.data) 
        Html.li({},
          Post.link(post.id, Html.text(post.title))
        )
      ]),
      if (nextPage <= totalPages)
        PostArchive.link(nextPage, Html.text('Next Page ->'))
      else null
    );
  }
}
