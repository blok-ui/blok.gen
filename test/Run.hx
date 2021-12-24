import blok.gen2.routing.Route;

using tink.CoreApi;
using Blok;

typedef Foo = Route<'test/{foo:String}', String>;

function main() {
  var foo = new Foo({
    load: (ctx:Context, foo:String) -> Promise.resolve('foo'),
    decode: (ctx:Context, foo:Dynamic) -> foo,
    render: (ctx:Context, foo:String) -> foo.text()
  });
  trace(foo);
}
