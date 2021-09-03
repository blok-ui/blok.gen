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

@page(route = '/')
class Home extends Page<Array<BlogPost>> {
  public function load():AsyncData<Dynamic> {
    return getContext()
      .getService(example.datasource.BlogPostDataSource)
      .findPosts(0, 3);
  }

  public function decode(data:Dynamic):Array<BlogPost> {
    return (data.field('data'):Array<Dynamic>).map(BlogPost.new);
  }

  public function metadata(data:Array<BlogPost>, meta:MetadataService) {
    meta.setPageTitle('Home'); 
  }

  public function render(posts:Array<BlogPost>) {
    return DefaultLayout.node({ 
      children: [
        Container.section(
          Container.header({ title: 'Home' }),
          Container.row(
            Container.column({ span: 6 },
              Html.p({},
                Html.text('This is an example of how `blok.gen` might work!')  
              )
            ),
            Container.column({ span: 3 },
              Html.h4({}, Html.text('Latest Posts')),
              Html.div({
                className: 'list-group'
              }, ...[ for (post in posts) 
                Post.link({
                  className: 'list-group-item list-group-item-action',
                  id: post.id 
                }, Html.text(post.title))  
              ]),
              PostArchive.link({
                page: 1
              }, Html.text('See All'))
            )
          )
        )
      ] 
    });
  }
}
