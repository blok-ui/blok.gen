package blok.gen.data;

typedef StoreResult<T> = {
  public final meta:{
    startIndex:Int,
    endIndex:Int,
    count:Int,
    total:Int
  };
  public final data:Array<T>;
}
