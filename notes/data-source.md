Data Sources
------------

Right now, our data loading approach is messy. We should replace it with something like the following:

```haxe

@page(route = '/')
class Home extends Page<StoreResult<BlogPost>> {
  #if blok.gen.build
    public function load():Promise<StoreResult<BlogPost>> {
      var source = new FileDataSource(config.build.root);
      return Promise.inParallel(
        source
          .listFiles('/data/post', file -> file.meta.extension == 'md') 
          .map(file -> config.build.formatters.get('md')
            .format(file.data)
            .next(data -> BlogPost.parse(file, data))
          )
      );
    }
  #end

  public function render(meta:MetadataService, posts:StoreResult<BlogPost>) {
    meta.setPageTitle('Home');
    return Html.div({},
      PageLink.node({
        url: '/post-archive/1',
        child: Html.text('Archives')
      }),
      Html.ul({}, ...[ for (post in posts.data) 
        Html.li({},
          Post.link(post.id, Html.text(post.title))
        )  
      ])
    );
  }
} 
```

Behind the scenes, the result of the `load` function will be saved next to the `index.html` file in `data.json`. In client mode, this json file will simply be loaded whenever the user routes to that page.

I think this will be the simplest and most flexible solution?
