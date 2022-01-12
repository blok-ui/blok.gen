Blok Gen
========

Static site generation for Blok.

> Note: This documentation is very much in progress. 

Getting Started
---------------

> Note: You should read the documentation on how Blok works first, as Blok Gen is built on top of those systems (especially the Context and Service framework).

Unlike other static generators, `blok.gen` does not use filesystem-based routing. Instead, you'll be setting up everything in an `AppModule`, which will set up routes, data sources, and any other services your app might require.

Before we dig into the AppModule, let's take a look at how routes work. Every `blok.gen.routing.Route` is a generic class that uses a macro behind the scenes to match against urls. Here's a simple one:

```haxe
package my.route;

import blok.gen.routing.Route;
import my.data.Post;

typedef PostRoute = Route<'/post/{id:Int}', Post>;
```

`PostRoute` is thus a Route that matches any url that starts with `/post/` followed by an `Int`. From this url, it produces a `my.data.Post`.

A route may have as many or as few params as you want (for example, an index route would look like `Route<'/', T>`), and params don't have to be placed behind slashes (for example, consider a post archive route that looks like `Route<'/post/archives/page-{id:Int}', T>`).

You'll link between pages in your app via macro-generated static methods on your Routes called `link` and `getUrl`.

```haxe
var url = PostRoute.getUrl({ id: 1 }); // => "/post/1"

// Or, inside a blok.Component:
Html.div({},
  PostRoute.link({ id: 1 }, Html.text('Go to post #1'))
);
// ... which is sugar for:
Html.div({},
  blok.gen.ui.PageLink.node({
    url: PostRoute.getUrl({ id: 1 }),
    children: [ Html.text('Go to post #1') ]
  })
);
```

An important note: you MUST use the `link` method (or `blok.gen.ui.PageLink`) to link between pages in your site, or Blok Gen won't be able to find them during the Build phase (more on that later).

Right now, this Route isn't very useful. Instead of a typedef, let's create a class:

```haxe
import blok.gen.routing.Route;

using Blok;

class PostRoute extends Route<'/post/{id:Int}', Post> {
  #if blok.platform.static
    public function load(context:Context, props:{ id:Int }) {
      return my.source.PostDataSource.from(context).get(id);
    }
  #end

  public function decode(context:Context, data:Dynamic) {
    return my.data.Post.fromJson(data);
  }

  public function render(context:Context, data:my.data.Post):VNode {
    return Html.div({},
      Html.header({}, data.title.text())
      // etc
    );
  }
}
```

As you can see, each route has three steps (run in this order): load, decode and render. The load step _only_ happens during the build phase, which is why it's wrapped in a guard checking for `blok.platform.static`.

> Note: this is how you can check for what phase the app is running in too: if it's generating static HTML, `blok.platform.static` will be present. If it's running in the browser, `blok.platform.dom` will be present.

`load` _must_ return a `tink.core.Promise<Dyanmic>` and the result should be an object that can be formatted into JSON. Note that the the `props.id` argument is available here from the url `/post/{id:Int}`.

`decode` is where you turn this JSON into something useable in the rest of your app. Here we're just using `blok.data.Record`'s `fromJson` feature, but this step might be more complex (or might not use `blok.data.Record`s at all).

The final step is `render`, which is where you return a `blok.ui.VNode` and render the page. When building, this will be turned into a HTML file (along with the needed data to hydrate the client app), and on the client it will be mounted on the app's root node.

> More coming.

