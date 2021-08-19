import blok.gen.client.ClientKernal;
import blog.Blog.config;
import blog.Blog.factory;

function main() {
  var kernal = new ClientKernal(config, factory);
  kernal.run();
}
