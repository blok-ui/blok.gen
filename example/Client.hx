import blok.gen.app.ClientKernel;

function main() {
  var kernal = new ClientKernel(new ExampleModule());
  kernal.run();
}
