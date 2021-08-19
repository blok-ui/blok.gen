package blog.pages;

import blok.Html;
import blok.gen.Page;
import blok.gen.MetadataService;
import blog.data.BlogPost;

using Reflect;
using tink.CoreApi;

class Post extends Page<Array<BlogPost>> {
  public function load(id:String):Promise<Array<BlogPost>> {
    return BlogPost
      .fromStore(store)
      .find({ id: id, includeSiblings: true });
  }

  public function render(meta:MetadataService, posts:Array<BlogPost>) {
    var post = posts[1];
    meta.setPageTitle('Post | ${post.title}');
    return Html.div({},
      post.content
    );
  }
}
