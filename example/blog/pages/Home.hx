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
      .find({ count: 10, first: 0 });
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
          PageLink.node({
            url: '/post/${post.id}',
            child: Html.text(post.title)
          })
        )  
      ])
    );
  }
}
