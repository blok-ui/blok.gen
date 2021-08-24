package blog.pages;

import blok.gen.PageLink;
import blok.Html;
import blok.gen.Page;
import blok.gen.MetadataService;
import blok.gen.data.StoreResult;
import blog.data.BlogPost;

using Reflect;
using tink.CoreApi;

class Post extends Page<StoreResult<BlogPost>> {
  public function load(id:String):Promise<StoreResult<BlogPost>> {
    return BlogPost
      .fromStore(store)
      .byId(id)
      .withSiblings()
      .fetch();
  }

  public function render(meta:MetadataService, posts:StoreResult<BlogPost>) {
    var post = posts.data[1];
    var previous = posts.data[0];
    var next = posts.data[2];

    meta.setPageTitle('Post | ${post.title}');
    
    return Html.div({},
      Html.h1({}, Html.text(post.title)),
      Html.div({}, post.content),
      if (previous != null) 
        Post.link(previous.id, Html.text('<-' + previous.title)) 
      else null,
      if (next != null) 
        Post.link(next.id, Html.text(next.title + ' ->')) 
      else null
    );
  }
}
