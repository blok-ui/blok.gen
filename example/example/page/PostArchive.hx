package example.page;

import example.ui.elements.Pagination;
import example.data.BlogPost;
import example.ui.layout.DefaultLayout;
import example.ui.elements.Container;

using Reflect;
using Blok;
using blok.GenApi;
using blok.gen.data.PaginationTools;

typedef PostArchiveWithPagination = {
  public final page:Int;
  public final totalPosts:Int;
  public final totalPages:Int;
  public final posts:Array<BlogPost>;
}

@page(route = 'post-archive')
class PostArchive extends PageRoute<PostArchiveWithPagination> {
  final perPage:Int;

  public function new(perPage) {
    super();
    this.perPage = perPage;
  }

  public function load(page:Int) {
    return getService(example.datasource.BlogPostDataSource)
      .findPosts(page.toIndex(perPage), perPage)
      .toObservableResult();
  }

  public function decode(data:Dynamic):PostArchiveWithPagination {
    var meta:{ startIndex:Int, total:Int } = data.field('meta');
    return {
      page: meta.startIndex.toPageNumber(perPage),
      totalPosts: meta.total,
      totalPages: meta.total.paginate(perPage),
      posts: (data.field('data'):Array<Dynamic>).map(BlogPost.new)
    };
  }
  
  public function render(data:PostArchiveWithPagination) {
    var pagination = [];
    if (data.page > 1) {
      pagination.push(Pagination.item({}, PostArchive.link({ 
        className: 'page-link',
        page: data.page - 1 
      }, Html.text('Previous'))));
    } else {
      pagination.push(Pagination.item({ isDisabled: true }, Html.span({
        className: 'page-link'
      }, Html.text('Previous'))));
    }
    for (page in 1...(data.totalPages+1)) {
      pagination.push(Pagination.item({
        isActive: page == data.page
      }, PostArchive.link({ 
        className: 'page-link',
        page: page 
      }, Html.text(Std.string(page)))));
    }
    if (data.page < data.totalPages) {
      pagination.push(Pagination.item({}, PostArchive.link({ 
        className: 'page-link',
        page: data.page + 1 
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
              }, ...[ for (post in data.posts) 
                Post.link({
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
