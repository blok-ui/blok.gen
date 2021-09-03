package example.page;

import example.ui.elements.Container;
import example.ui.layout.DefaultLayout;
import blok.gen.AsyncData;
import blok.gen.Page;
import blok.gen.MetadataService;
import example.data.BlogPost;

using Blok;
using Reflect;
using tink.CoreApi;

typedef PostWithSiblings = {
  public final prev:Null<BlogPost>;
  public final next:Null<BlogPost>;
  public final current:BlogPost;
}

class Post extends Page<PostWithSiblings> {
  public function load(id:String):AsyncData<Dynamic> {
    return getContext()
      .getService(example.datasource.BlogPostDataSource)
      .getPost(id);
  }

  public function decode(data:Dynamic):PostWithSiblings {
    var meta:{ next:Dynamic, prev:Dynamic } = data.field('meta');
    return {
      next: if (meta.next != null) new BlogPost(meta.next) else null,
      prev: if (meta.prev != null) new BlogPost(meta.prev) else null,
      current: new BlogPost(data.field('data'))
    };
  }

  public function metadata(data:PostWithSiblings, meta:MetadataService) {
    meta.setPageTitle('Post | ' + data.current.title);
  }
  
  public function render(posts:PostWithSiblings) {
    return DefaultLayout.node({
      children: [
        Container.section(
          Container.header({ title: posts.current.title }),
          Container.row(  
            Container.column({}, posts.current.content)
          ),
          Container.row(
            Container.column({},
              Html.ul({ className: 'nav' },
                Html.li({ className: 'nav-item' },
                  if (posts.prev != null)
                    Post.link({
                      className: 'nav-link',
                      id: posts.prev.id 
                    }, Html.text(posts.prev.title))
                  else 
                    Html.span({
                      className: 'nav-link disabled'
                    }, Html.text('At End'))
                ),
                Html.li({ className: 'nav-item' },
                  if (posts.next != null) 
                    Post.link({
                      className: 'nav-link',
                      id: posts.next.id
                    }, Html.text(posts.next.title)) 
                  else 
                    Html.span({
                      className: 'nav-link disabled'
                    }, Html.text('At End'))
                )
              )
            )
          )
        )
      ]
    });
  }
}
