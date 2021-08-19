package blok.gen.data;

@service(fallback = throw 'No service was registered')
class StoreService implements Service {
  final store:Store;

  public function new(store) {
    this.store = store;
  }

  public function getStore() {
    return store;
  }
}
