package blog.pages;

import blog.data.BlogPost;
import blok.Html;
import blok.gen.Page;
import blok.gen.PageLink;
import blok.gen.MetadataService;

using Reflect;
using tink.CoreApi;

@page(route = '/')
class Home extends Page<Array<BlogPost>> {
  public function load():Promise<Array<BlogPost>> {
    return BlogPost
      .fromStore(store)
      .find({ count: 10, first: 0 });
  }

  public function render(meta:MetadataService, data:Array<BlogPost>) {
    meta.setPageTitle('Home');
    return Html.div({},
      PageLink.node({
        url: '/post-archive/1',
        child: Html.text('Archives')
      }),
      Html.ul({}, ...[ for (post in data) 
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
