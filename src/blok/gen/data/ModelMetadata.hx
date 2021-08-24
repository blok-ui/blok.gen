package blok.gen.data;

import blok.gen.data.ModelPropsParser;

typedef ModelMetadata<T:Model> = {
  public final name:String;
  public final extension:String;
  public final idProperty:String;
  public function create(props:Null<Dynamic>):Null<T>;
  #if blok.gen.ssr
    public final parse:ModelPropsParser;
  #end
}
