package blok.gen.storage;

using tink.CoreApi;

interface Reader {
  public function list(path:String, filter:(name:String)->Bool):Promise<Array<FileResult>>;
  public function read(path:String):Promise<FileResult>;
}
