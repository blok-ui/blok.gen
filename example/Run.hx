#if blok.platform.static
  import blok.gen.app.StaticKernel as Kernel;
#else 
  import blok.gen.app.ClientKernel as Kernel;
#end

function main() {
  var kernel = new Kernel(new ExampleModule());
  kernel.run();
}
