import blok.gen.client.ClientKernal;
import blog.Blog.config;
import blog.Blog.routes;

function main() {
  var kernal = new ClientKernal(config, routes);
  kernal.run();
}
