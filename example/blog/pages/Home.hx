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
  public function load() {
    return blog.datasource.BlogPostDataSource.findPosts(config.ssr, 0, 100);
  }

  public function decode(data:Dynamic):Array<BlogPost> {
    return (data.field('data'):Array<Dynamic>).map(BlogPost.new);
  }

  public function render(meta:MetadataService, posts:Array<BlogPost>) {
    meta.setPageTitle('Home');
    return Html.div({},
      PageLink.node({
        url: '/post-archive/1',
        child: Html.text('Archives')
      }),
      Html.ul({}, ...[ for (post in posts) 
        Html.li({},
          Post.link(post.id, Html.text(post.title))
        )  
      ])
    );
  }
}
