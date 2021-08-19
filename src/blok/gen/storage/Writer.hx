package blok.gen.storage;

using tink.CoreApi;

interface Writer {
  public function write(path:String, data:String):Promise<Noise>;  
}
