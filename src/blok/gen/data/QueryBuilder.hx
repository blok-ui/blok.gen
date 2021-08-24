package blok.gen.data;

using haxe.io.Path;
using blok.tools.ObjectTools;

enum QueryPart {
  QueryId(id:String);
  QuerySiblings;
  QueryCount(count:Int);
  QueryFirst(index:Int);
  QueryChild(filename:String);
}

class QueryBuilder<T:Model> {
  final meta:ModelMetadata<T> = null;
  final store:Store;
  final parts:Array<QueryPart> = [];

  public function new(meta, store) {
    this.meta = meta;
    this.store = store;
  }

  public function byId(id) {
    parts.push(QueryId(id));
    return this;
  }

  public function startingAt(index:Int) {
    parts.push(QueryFirst(index));
    return this;
  }

  public function includeSiblings() {
    parts.push(QuerySiblings);
    return this;
  }

  public function count(count:Int) {
    parts.push(QueryCount(count));
    return this;
  }

  /**
    `byChild` is handy if your data is grouped in folders
    that have a document inside: for example, `foo/index.md` rather
    than `foo.md`.
  **/
  public function byChild(filename:String) {
    parts.push(QueryChild(filename));
    return this;
  }

  public function getHash():Int {
    return (meta.name + [ for (part in parts) switch part {
      case QuerySiblings: 'with-siblings';
      case QueryCount(count): 'count-$count';
      case QueryId(id): 'id-$id';
      case QueryFirst(index): 'first-$index';
      case QueryChild(filename): 'child-$filename';
    } ].join('_')).hash();
  }

  public function getJsonName() {
    return Std.string(getHash()).withExtension('json');
  }

  public function fetch() {
    
  }
}
