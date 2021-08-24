package blok.gen.data;

using tink.CoreApi;

interface Store {
  public function find<T:Model>(query:QueryBuilder<T>):Promise<StoreResult<T>>;
}
