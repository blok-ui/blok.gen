import blok.gen.client.ClientKernal;
import example.Site;

function main() {
  var kernal = new ClientKernal(new Site());
  kernal.run();
}
