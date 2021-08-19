package blok.gen.data;

using tink.CoreApi;

interface Store {
  public function find<T:Model>(query:Query<T>):Promise<Array<T>>;
}
