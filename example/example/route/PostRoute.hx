package example.route;

import blok.context.Context;
import blok.gen2.content.ContentRenderer;
import blok.gen2.routing.Route;
import example.data.BlogPost;
import example.ui.elements.Container;
import example.ui.layout.DefaultLayout;

#if blok.platform.static
  import example.datasource.BlogPostDataSource;
#end

using Blok;
using Reflect;
using tink.CoreApi;

typedef PostWithSiblings = {
  public final prev:Null<BlogPost>;
  public final next:Null<BlogPost>;
  public final current:BlogPost;
}

class PostRoute extends Route<'/post/{id:String}', PostWithSiblings> {
  #if blok.platform.static
    function load(context:blok.context.Context, props:{id:String}):Promise<Dynamic> {
      return BlogPostDataSource.from(context).getPost(props.id);
    }
  #end

  public function decode(context:Context, data:Dynamic):PostWithSiblings {
    var meta:{ next:Dynamic, prev:Dynamic } = data.field('meta');
    return {
      next: if (meta.next != null) BlogPost.fromJson(meta.next) else null,
      prev: if (meta.prev != null) BlogPost.fromJson(meta.prev) else null,
      current: BlogPost.fromJson(data.field('data'))
    }
  }

  public function render(context:Context, data:PostWithSiblings) {
    var prev = data.prev;
    var next = data.next;
    var post = data.current;

    return DefaultLayout.node({
      pageTitle: 'Post | ' + post.title,
      children: [
        Container.section(
          Container.header({ title: post.title }),
          Container.row(  
            Container.column({}, ContentRenderer.renderContent(post.content))
          ),
          Container.row(
            Container.column({},
              Html.ul({ className: 'nav' },
                Html.li({ className: 'nav-item' },
                  if (prev != null)
                    PostRoute.link({
                      className: 'nav-link',
                      id: prev.id 
                    }, Html.text(prev.title))
                  else 
                    Html.span({
                      className: 'nav-link disabled'
                    }, Html.text('At End'))
                ),
                Html.li({ className: 'nav-item' },
                  if (next != null) 
                    PostRoute.link({
                      className: 'nav-link',
                      id: next.id
                    }, Html.text(next.title)) 
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
