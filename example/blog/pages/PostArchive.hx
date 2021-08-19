package blog.pages;

import blok.gen.MetadataService;
import blog.data.BlogPost;
import blok.gen.Page;
import blok.gen.PageLink;

using Blok;

@page(route = 'post-archive')
class PostArchive extends Page<Array<BlogPost>> {
  public function load(pageNum:String) {
    var page = Std.parseInt(pageNum);
    var first = page == 1 ? 0 : page * 10;
    return BlogPost
      .fromStore(store)
      .find({ first: first, count: 10 });
  }

  public function render(meta:MetadataService, posts:Array<BlogPost>) {
    meta.setPageTitle('Post Archives');
    return Html.div({},
      Html.ul({}, ...[ for (post in posts) 
        Html.li({},
          PageLink.node({
            url: '/post/${post.id}',
            child: Html.text(post.title)
          })
        )  
      ])
    );
  }
}
