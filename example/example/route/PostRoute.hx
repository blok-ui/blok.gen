package example.route;

import blok.gen2.routing.Route;
import example.data.BlogPost;

typedef PostWithSiblings = {
  public final prev:Null<BlogPost>;
  public final next:Null<BlogPost>;
  public final current:BlogPost;
}

typedef PostRoute = Route<'/post/{id:String}', PostWithSiblings>;
