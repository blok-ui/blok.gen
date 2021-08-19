package blok.gen.data;

using StringTools;
using haxe.io.Path;

class Query<T:Model> implements Record {
  @prop public var meta:ModelMetadata<T> = null;
  @prop public var first:Int = 0;
  @prop public var count:Int = 1;
  @prop public var includeSiblings:Bool = false;
  @prop public var id:Null<String> = null;

  public function toString() {
    var specifiers =  if (id != null) {
      'by-id_' + id.replace(' ', '-') + '_${includeSiblings ? 'sibs' : 'no-sibs'}';
    } else {
      '${first}_${count}_${includeSiblings ? 'sibs' : 'no-sibs'}';
    }
    return '${meta.name}__${specifiers}';
  }

  public function asJsonName() {
    return toString().withExtension('json');
  }
}
