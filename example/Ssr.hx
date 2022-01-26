import blok.gen.app.StaticKernel;

function main() {
  var kernal = new StaticKernel(new ExampleModule());
  kernal.run();
}
