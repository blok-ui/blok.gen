package blog.pages;

import blok.gen.PageLink;
import blok.Html;
import blok.gen.Page;
import blok.gen.MetadataService;
import blog.data.BlogPost;

using Reflect;
using tink.CoreApi;

typedef PostWithSiblings = {
  public final prev:Null<BlogPost>;
  public final next:Null<BlogPost>;
  public final current:BlogPost;
}

class Post extends Page<PostWithSiblings> {
  public function load(id:String) {
    return blog.datasource.BlogPostDataSource.getPost(config.ssr, id);
  }

  public function decode(data:Dynamic):PostWithSiblings {
    var meta:{ next:Dynamic, prev:Dynamic } = data.field('meta');
    return {
      next: if (meta.next != null) new BlogPost(meta.next) else null,
      prev: if (meta.prev != null) new BlogPost(meta.prev) else null,
      current: new BlogPost(data.field('data'))
    };
  }

  public function render(meta:MetadataService, posts:PostWithSiblings) {
    meta.setPageTitle('Post | ${posts.current.title}');
    
    return Html.div({},
      Html.h1({}, Html.text(posts.current.title)),
      Html.div({}, posts.current.content),
      if (posts.prev != null) 
        Post.link(posts.prev.id, Html.text('<-' + posts.prev.title)) 
      else null,
      if (posts.next != null) 
        Post.link(posts.next.id, Html.text(posts.next.title + ' ->')) 
      else null
    );
  }
}
