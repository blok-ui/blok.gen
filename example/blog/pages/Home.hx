package blog.pages;

import blog.data.BlogPost;
import blok.Html;
import blok.gen.Page;
import blok.gen.PageLink;
import blok.gen.MetadataService;
import blok.gen.data.StoreResult;

using Reflect;
using tink.CoreApi;

@page(route = '/')
class Home extends Page<StoreResult<BlogPost>> {
  public function load():Promise<StoreResult<BlogPost>> {
    return BlogPost
      .fromStore(store)
      .all()
      .sortBy(SortCreated)
      .fetch();
  }

  public function render(meta:MetadataService, posts:StoreResult<BlogPost>) {
    meta.setPageTitle('Home');
    return Html.div({},
      PageLink.node({
        url: '/post-archive/1',
        child: Html.text('Archives')
      }),
      Html.ul({}, ...[ for (post in posts.data) 
        Html.li({},
          Post.link(post.id, Html.text(post.title))
        )  
      ])
    );
  }
}
