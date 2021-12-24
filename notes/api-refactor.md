Refactor
========

The current system works, but is a bit of a mess.

Here are some ideas for a refactor:

Structure
---------

All `blok.gen` apps start with a `Kernel`, which is in charge of resolving dependencies and bootstrapping the application.

Dependencies are provided by `Modules`, which are themselves just `blok.ServiceProvider`s.

The core of `blok.gen` is based around its routing and data-source systems. Routes intentionally mirror blok's Widget system, and are composable (note: it might be cool to actually use Components as our routes). Routes look like this:

```haxe
typedef Post = { 
  id: Int,
  slug:String,
  content: String
}

typedef PostRoute = Route<'/blog/{slug:String}', Post>;
```

The route will use a macro to parse `"/blog/{slug:String}"` (via a `:genericBuild` macro) and create a matcher. Using this route requires two things: a `dataSource` and a `render` callback. Note that the `dataSource` is ONLY used in static contexts -- on the DOM, a per-page system is used instead.

```haxe
var route = new PostRoute({
  #if blok.platform.static
    load: (context:Context, slug:String) -> 
      BlogDataSource.from(context).getPost(slug),
  #end
  render: (context:Context, data:Post) -> Html.div({},
    Html.h2({}, Html.text(data.slug)),
    // etc
  )
});
```

In some cases, you might want to compose routes, or provide some parent data. For example, here's what a BlogCategory might look like:

```haxe
typedef Category = { name:String };
typedef Post = { 
  id: Int,
  slug:String,
  content: String
}

typedef BlogCategory = Route<'/blog/{category:String}', Category>;

var route = new BlogCategory({
  #if blok.platform.static
    load: (context:Context, category:String) -> 
      BlogDataSource.from(context).getCategory(category),
  #end
  provide: (context:Context, category:Category) -> {
    // Anything provided here will be avilable to all this route's
    // children via Blok's Context API.
    context.set('category', category);
  },
  render: (context:Context, category:Category) -> {
    // stuff
  },
  children: [
    new Route<'{slug:String}', Post>({
      #if blok.platform.static
        load: (context:Context, slug:String) -> 
          BlogDataSource.from(context).getPost(slug),
      #end
      render: (context:Context, data:Post) -> {
        var category:Category = context.get('category');
        return Html.div({},
          Html.h2({}, Html.text(category.name + ' | ' +  data.slug)),
          // etc
        );
      }
    });
  ]
});
```

This same method can be used to set up global data via the `GlobalRoute`, which matches everything:

```haxe
var root = new GlobalRoute({
  #if blok.platform.static
    load: (context:Context) -> {
      return new ObservableResult(Ok({ title: "My Site" }));
    },
  #end
  children: [
    blogCategory,
    myOtherPage,
    // etc
  ]
})
```
