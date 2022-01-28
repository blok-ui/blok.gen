Blok Gen
========

Static site generation for Blok.

> Note: This documentation is very much in progress. 

Installation
------------

Right now, `blok.gen` is only available via `lix`.

```
lix install gh:blok-ui/blok.gen
```

Creating a Site
---------------

Here's a detailed guide about how to use Blok Gen.

### Routes

Unlike other static site generators, `blok.gen` does not use the filesystem to generate routes. Instead, routes are defined by extending the `blok.gen.routing.Route` class. Here's an example:

```haxe
package example.route;

import blok.gen.routing.Route;

using Blok;

typedef HomeData = {
  public final name:String;
}

class HomeRoute extends Route<'/', HomeData> {}
```

The type parameters on `Route` are important -- the first is a string (processed behind the scenes by a generic build macro) that is used to match against the current URL, and the second is the data that the Route will receive.

In this case our Route's path is simple -- it's just `'/'`, which will be used for our home page. However you'll often need to get some parameters from the route, and `blok.gen` has simple syntax for that:

```haxe
package example.route

import blok.gen.routing.Route;

typedef PostRouteData = {
  public final id:String;
  public final content:String;
}

using Blok;

class PostRoute extends Route<'/post/{id:String}', PostData> {}
```

The above example will match URLs like "/post/foo" and "/post/bar", but not "/post/1". If you wanted to only match integers, you'd use `'/post/{id:Int}'`. You can even get more granular than this using a regular expression, like `'/post/{id:[A-Z]*}'` to only match uppercase letters (or anything else you want).

Right now neither of these examples will work -- in fact, haxe won't even compile them, and will complain that they're missing required fields. Let's start with our `HomeRoute` and implement the methods we're missing:

```haxe
package example.route;

import blok.gen.routing.Route;

#if blok.platform.static
  import blok.gen.source.FormattedDataSource;
#end

using Blok;
using tink.CoreApi;

typedef HomeData = {
  public final name:String;
}

class HomeRoute extends Route<'/', HomeData> {
  #if blok.platform.static
    public function load(context:Context, props:{}):Promise<Dynamic> {
      var source = FormattedDataSource.from(context);
      return source.get('site.toml').next(result -> result.formatted);
    }
  #end

  public function decode(context:Context, data:Dynamic):HomeData {
    return data;
  }

  public function render(context:Context, data:HomeData):VNode {
    return Html.div({},
      Html.h1({}, Html.text(data.name))
    );
  }
}
```

There's a lot going on here, so let's go step by step.

First off, there is our `load` method. This is only used when generating the static site, which is why it's wrapped in the `#if blok.platform.static` guard. You'll note that `load` has two parameters -- `context` and `props`. `context` is a `blok.context.Context`, which ties into Blok's context API. We'll get into this more when we talk about `Module`s, but for now just understand that it's how we pass dependencies around in Blok.

`props` is where we get access to the parameters from our Route's path. In this case we don't have any, but our `PostRoute` would look something like this:

```haxe
class PostRoute extends Route<'/post/{id:String}', PostData> {
  #if blok.platform.static
    public function load(context:Context, props:{ id:String }):Promise<Dynamic> {
     // ...
    }
  #end

  // ...
}
```

Inside the method itself, we get a `FormattedDataSource` (more on that in a second) from the `context` and use it to load the `site.toml` file.

We then need to `decode` the data we received from `load`. The `data` parameter will always be a simple JSON object, regardless of what format the source file was in. In this case, we don't need to do anything to the JSON -- we can just return it and cast it into a `HomeData`.

The final step is `render`, where we transform the `data` into a `VNode` that will be shown to the user.

This is probably a good time to look into _where_ this data comes from, so lets step up a level and talk about configuration.

### Modules

All of your app's configuration happens in one place -- the `AppModule`. Here's an example:

```haxe
package example;

import blok.context.ServiceProvider;
import blok.gen.app.AppModule;
import blok.gen.core.Config;
import blok.gen.routing.Matchable;

class ExampleModule extends AppModule {
  function provideConfig():Config {
    // ...
  }
  
  function provideRoutes():Array<Matchable> {
    return [
      new example.route.HomeRoute(),
      new example.route.PostRoute()
    ];
  }
  
  function provideServices():Array<ServiceProvider> {
    // ...
  }
  
  #if blok.platform.static
    function provideDataSources():Array<ServiceProvider> {
      // ..
    }
  #end
}
```

`AppModule` is an abstract class that requires you to implement `provideConfig`, `provideRoutes`, `provideServices`, and `provideDataSources`. Implementing `provideRoutes` is simple -- we're just returning an array of the routes we created earlier in this guide (of note: `blok.gen.routing.Route` implements `blok.gen.routing.Matchable`).

Let's provide a `Config` too. This will tell our app where to look for data, what it should render if it can't find a matching route, and other useful things:

```haxe
  function provideConfig():Config {
    return new Config({
      site: new SiteConfig({
        url: 'http://localhost:5000',  
        title: 'Test',
        // The id of the root element Blok will mount your app on: 
        rootId: 'root',
        // The folder assets should be found in:
        assetPath: '/assets',
        // A list of assets (can be `AssetCss` and `AssetJs`). The second
        // parameter marks if it is local (true) or not (false). If the
        // asset is local, Blok will look for it in the `assetPath` defined
        // above.
        assets: [
          AssetCss('styles.css', true),
          AssetCss('https://cdn.jsdelivr.net/npm/bootstrap@5.1.0/dist/css/bootstrap.min.css', false)
        ]
      }),
      // Defines the views that will be shown if an error is encountered
      // or if a page is loading and no previously rendered page is
      // available (which is very rare, to the point that it should never
      // happen unless your server goes down).
      //
      // You should provide more than just a `Html.text` like we're 
      // doing here. 
      view: new ViewConfig({
        error: e -> Html.text(e.message),
        loading: () -> Html.text('loading')
      }),
      #if blok.platform.static
        // The `ssr` config tells the app where to load data from, and where
        // to put all generated files. All paths used in data sources
        // should be relative to these.
        ssr: new SsrConfig({
          source: Path.join([ Sys.programPath().directory().directory(), 'example/data' ]),
          destination: Path.join([ Sys.programPath().directory().directory(), 'dist/www' ])
        })
      #end
    });
  }
```

Now that that's done, let's set up our data sources. `blok.gen` provides a few common ones, but you'll likely define your own. For this example, however, let's just use a `FormattedDataSource` and set it up to process `toml` and `md` files:

```haxe
  #if blok.platform.static
    function provideDataSources():Array<ServiceProvider> {
      return [
        new blok.gen.source.FormattedDataSource([
          'md' => new blok.formatter.MarkdownFormatter(
            // Note: this is the formatter to use for frontmatter
            new blok.formatter.TomlFormatter()
          ),
          'toml' => new blok.formatter.TomlFormatter()
        ]),
      ];
    }
  #end
```

If you look at the source for `blok.gen.source.FormattedDataSource`, you'll see that it uses `blok.gen.source.FileDataSource` internally. We can return a `FileDataSource` from `provideDataSources`, but Blok's context API will automatically create a `FileDataSource` using our `Config`, so we can omit it.

> Note: This is done with the `@service(fallback = ...)` metadata you'll see on all `blok.context.Service`s.

We don't have any other services we need to use for this example right now, so we can just return an empty array from `provideServices`.

```haxe
  function provideServices():Array<ServiceProvider> {
    return [];
  }
```

### Running your App

Now all we need to do is run our app. Let's create our main function (we'll call it `Run.hx`, but you can go with whatever name you prefer):

```haxe
#if blok.platform.static
  import blok.gen.app.StaticKernel as Kernel;
#else 
  import blok.gen.app.ClientKernel as Kernel;
#end

function main() {
  var kernel = new Kernel(new ExampleModule());
  kernel.run();
}
```

...and then set up our `build.hxml`:

```hxml
-cp src

-lib blok.gen

-main Run

# The following are optional, but encouraged:
-dce full
-D js-es=6
-D analyzer-optimize

--each
# The client app
-lib blok.platform.dom

# Note: This needs to be the same folder as `config.site.assets` and
# should be called `app.js` (although you can change the name by setting
# `config.site.appName)
-js dist/www/assets/app.js

--next
# The site generator

# from `haxelib:hxnodejs`
# Note: you don't need to use node for this -- any target that
# supports the sys api will function for the generator.
-lib hxnodejs
# from `gh:wartman/toml`
-lib toml
# from `haxelib:markdown`
-lib markdown
-lib blok.platform.static

-js generate/index.js
# Optionally generate the site every time you build the app
-cmd node generate
```

Build your app, and `dist/www` should be filled with a mix of `json`, `html` and `js` that you can drop on any static server (or run a local server on with something like `serve` from NPM).

> Todo: This document is incomplete.
>
> More to come soon! For now, just take a look at the "example" folder in this repo.
