package example.ui.page;

import example.ui.elements.Container;
import example.ui.layout.DefaultLayout;
import example.route.PostRoute;
import example.route.PostArchiveRoute;
import example.data.BlogPost;

using Blok;

class Home extends Component {
  @prop var posts:Array<BlogPost>;

  function render() {
    return DefaultLayout.node({ 
      pageTitle: 'Home',
      children: [
        Container.section(
          Container.header({ title: 'Home' }),
          Container.row(
            Container.column({ span: 6 },
              Html.p({},
                Html.text('This is an example of how `blok.gen2` might work!')  
              )
            ),
            Container.column({ span: 3 },
              Html.h4({}, Html.text('Latest Posts')),
              Html.div({
                className: 'list-group'
              }, ...[ for (post in posts) 
                PostRoute.link({
                  className: 'list-group-item list-group-item-action',
                  id: post.id 
                }, Html.text(post.title))  
              ]),
              PostArchiveRoute.link({ page: 1 }, Html.text('See All'))
            )
          )
        )
      ] 
    });
  }
}
