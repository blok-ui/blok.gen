import blok.gen.client.ClientKernal;
import example.Blog.config;
import example.Blog.routes;

function main() {
  var kernal = new ClientKernal(config, routes);
  kernal.run();
}
