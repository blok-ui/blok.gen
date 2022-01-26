package example.route;

import blok.data.Record;
import blok.gen.routing.Route;
import example.data.BlogPost;
import example.data.BlogConfig;
import example.ui.layout.DefaultLayout;
import example.ui.elements.Pagination;
import example.ui.elements.Container;

#if blok.platform.static
  import example.datasource.BlogPostDataSource;
#end

using Blok;
using Reflect;
using blok.gen.data.PaginationTools;

class PostArchiveWithPagination implements Record {
  @prop var page:Int;
  @prop var totalPosts:Int;
  @prop var totalPages:Int;
  @prop var posts:Array<BlogPost>;
}

class PostArchiveRoute
  extends Route<'/post-archive/page-{page:Int}', PostArchiveWithPagination> 
{
  #if blok.platform.static
    function load(context:Context, props:{ page:Int }) {
      var perPage = BlogConfig.from(context).perPage;
      return BlogPostDataSource
        .from(context)
        .findPosts(props.page.toIndex(perPage), perPage);
    }
  #end

  function decode(context:Context, data:Dynamic) {
    var perPage = BlogConfig.from(context).perPage;
    var meta:{ startIndex:Int, total:Int } = data.field('meta');
    return PostArchiveWithPagination.fromJson({
      page: meta.startIndex.toPageNumber(perPage),
      totalPosts: meta.total,
      totalPages: meta.total.paginate(perPage),
      posts: data.field('data')
    });
  }
  
  function render(context:Context, data:PostArchiveWithPagination) {
    var pagination = [];
    var totalPages = data.totalPages;
    var totalPosts = data.totalPosts;
    var page = data.page;
    var posts = data.posts;
    
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
