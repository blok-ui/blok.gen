package example.route;

import blok.context.Context;
import blok.gen.routing.Route;
import example.data.BlogPost;
import example.data.BlogConfig;
import example.ui.elements.Container;
import example.ui.layout.DefaultLayout;

#if blok.platform.static
  import example.datasource.BlogPostDataSource;
#end

using Reflect; 
using Blok;
using tink.CoreApi;

class HomeRoute extends Route<'/', Array<BlogPost>> {
  #if blok.platform.static
    function load(context:blok.context.Context, props:{}):Promise<Dynamic> {
      return BlogPostDataSource
        .from(context)
        .findPosts(0, BlogConfig.from(context).perPage);
    }
  #end

  public function decode(context:Context, data:Dynamic) {
    return (data.field('data'):Array<Dynamic>).map(BlogPost.fromJson);
  }

  public function render(context:Context, posts:Array<BlogPost>) {
    return DefaultLayout.node({ 
      pageTitle: 'Home',
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
