package blok.gen.data;

class ModelStore<T:Model> {
  final meta:ModelMetadata<T>;
  final store:Store;

  public function new(meta, store) {
    this.meta = meta;
    this.store = store;
  }

  public function find(options) {
    var query = new Query(options);
    return store.find(query.withMeta(meta));
  }
}
