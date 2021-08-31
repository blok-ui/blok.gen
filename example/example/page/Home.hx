package example.page;

import example.ui.layout.DefaultLayout;
import blok.gen.AsyncData;
import blok.gen.Page;
import blok.gen.MetadataService;
import example.data.BlogPost;

using Blok;
using Reflect;
using tink.CoreApi;

@page(route = '/')
class Home extends Page<Array<BlogPost>> {
  public function load():AsyncData<Dynamic> {
    return getContext()
      .getService(example.datasource.BlogPostDataSource)
      .findPosts(0, 100);
  }

  public function decode(data:Dynamic):Array<BlogPost> {
    return (data.field('data'):Array<Dynamic>).map(BlogPost.new);
  }

  public function metadata(data:Array<BlogPost>, meta:MetadataService) {
    meta.setPageTitle('Home'); 
  }

  public function render(posts:Array<BlogPost>) {
    return DefaultLayout.node({ 
      children: [
        Html.ul({}, ...[ for (post in posts) 
          Html.li({},
            Post.link(post.id, Html.text(post.title))
          )  
        ])
      ] 
    });
  }
}
