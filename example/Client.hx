import blok.gen.client.ClientKernal;
import example.Blog.config;
import example.Blog.routes;
import example.Blog.services;

function main() {
  var kernal = new ClientKernal(config, routes, services);
  kernal.run();
}
