import blok.gen2.app.StaticKernel;

function main() {
  var kernal = new StaticKernel(new ExampleModule());
  kernal.run();
}
