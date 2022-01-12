import blok.gen2.routing2.RouteResult;
import blok.gen2.routing.Route;

using tink.CoreApi;
using Blok;

// typedef Foo = Route<'test/{foo:String}', String>;

function main() {
  // var foo = new Foo({
  //   load: (ctx:Context, foo:String) -> Promise.resolve('foo'),
  //   decode: (ctx:Context, foo:Dynamic) -> foo,
  //   render: (ctx:Context, foo:String) -> foo.text()
  // });
  // trace(foo);

  trace(Bar);
}

class Bar extends blok.gen2.routing2.Route<'test/{foo:String}', String> {
	function decode(context:blok.context.Context, data:Dynamic):String {
		return data;
	}

  #if blok.platform.static 
    function load(context:blok.context.Context, params:{foo:String}):tink.core.Promise<Dynamic> {
      throw new haxe.exceptions.NotImplementedException();
    }
  #end

	function render(context:blok.context.Context, data:String):blok.ui.VNode {
		throw new haxe.exceptions.NotImplementedException();
	}
}
