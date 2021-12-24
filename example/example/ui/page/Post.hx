package example.ui.page;

import blok.gen2.content.ContentRenderer;
import example.route.PostRoute;
import example.ui.elements.Container;
import example.ui.layout.DefaultLayout;
import example.data.BlogPost;

using Blok;
using Reflect;
using tink.CoreApi;

class Post extends Component { 
  @prop var prev:Null<BlogPost>;
  @prop var next:Null<BlogPost>;
  @prop var post:BlogPost;

  function render() {
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