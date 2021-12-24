package example.ui.page;

import example.route.PostRoute;
import example.data.BlogPost;
import example.route.PostArchiveRoute;
import example.ui.layout.DefaultLayout;
import example.ui.elements.Pagination;
import example.ui.elements.Container;

using Blok;

class PostArchive extends Component {
  @prop var page:Int;
  @prop var totalPosts:Int;
  @prop var totalPages:Int;
  @prop var posts:Array<BlogPost>;
  
  function render() {
    var pagination = [];
    if (page > 1) {
      pagination.push(Pagination.item({}, PostArchiveRoute.link({ 
        className: 'page-link',
        page: page - 1 
      }, Html.text('Previous'))));
    } else {
      pagination.push(Pagination.item({ isDisabled: true }, Html.span({
        className: 'page-link'
      }, Html.text('Previous'))));
    }
    for (page in 1...(totalPages+1)) {
      pagination.push(Pagination.item({
        isActive: page == page
      }, PostArchiveRoute.link({ 
        className: 'page-link',
        page: page 
      }, Html.text(Std.string(page)))));
    }
    if (page < totalPages) {
      pagination.push(Pagination.item({}, PostArchiveRoute.link({ 
        className: 'page-link',
        page: page + 1 
      }, Html.text('Next'))));
    } else {
      pagination.push(Pagination.item({ isDisabled: true }, Html.span({
        className: 'page-link'
      }, Html.text('Next'))));
    }

    return DefaultLayout.node({ 
      pageTitle: 'Post Archives',
      children: [
        Container.section(
          Container.header({ title: 'Archives' }),
          Container.row(
            Container.column({},
              Html.div({
                className: 'list-group'
              }, ...[ for (post in posts) 
                PostRoute.link({
                  className: 'list-group-item list-group-item-action',
                  id: post.id 
                }, Html.text(post.title))  
              ])
            ),
            Container.row(
              Container.column({},
                Pagination.container(...pagination)
              )
            )
          )
        )
      ] 
    });
  }
}