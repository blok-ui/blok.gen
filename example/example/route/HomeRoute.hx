package example.route;

import blok.gen2.routing.Route;
import example.data.BlogPost;

typedef HomeRoute = Route<'/', Array<BlogPost>>; 
