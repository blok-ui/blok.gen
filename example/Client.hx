import blok.gen2.app.ClientKernel;

function main() {
  var kernal = new ClientKernel(new ExampleModule());
  kernal.run();
}
