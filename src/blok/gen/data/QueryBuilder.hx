package blok.gen.data;

using haxe.io.Path;
using blok.tools.ObjectTools;

@:using(blok.gen.data.QueryBuilder.QueryModifierTools)
enum QueryModifier {
  QueryWithSiblings;
  QueryChild(name:String);
  QueryExtension(ext:String);
  QuerySort(sort:SortBy);
}

enum abstract SortBy(String) from String to String {
  var SortCreated = 'created';
  var SortUpdated = 'updated';
  var SortName = 'name';
}

class QueryModifierTools {
  public static function getValue(mod:Null<QueryModifier>) {
    if (mod == null) return null;
    return switch mod {
      case QueryWithSiblings: '';
      case QueryChild(name): name;
      case QueryExtension(ext): ext;
      case QuerySort(sort): sort;
    }
  }
}

enum QueryType {
  QueryNone;
  QueryById(id:String, modifiers:Array<QueryModifier>);
  QueryAll(modifiers:Array<QueryModifier>);
  QueryRange(first:Int, count:Int, modifiers:Array<QueryModifier>);
}

class QueryBuilder<T:Model> {
  public final meta:ModelMetadata<T> = null;
  public final store:Store;
  public var type(default, null):QueryType = QueryNone;
  var hash:Null<Int> = null;

  public function new(meta, store) {
    this.meta = meta;
    this.store = store;
  }

  public function byId(id:String) {
    hash = null;
    type = QueryById(id, []);
    return this;
  }

  public function all() {
    hash = null;
    type = QueryAll([]);
    return this;
  }

  public function range(start:Int, count:Int) {
    hash = null;
    type = QueryRange(start, count, []);
    return this;
  }
  
  public function withSiblings() {
    switch type {
      case QueryById(id, modifiers):
        hash = null;
        type = QueryById(id, modifiers.concat([ QueryWithSiblings ]));
      default:
        throw 'QueryBuilder.withSiblings only works on byId queries';
    }
    return this;
  }

  public function ofChildren(name:String) {
    addModifier(QueryChild(name));
    return this;
  }

  public function withExtension(ext:String) {
    addModifier(QueryExtension(ext));
    return this;
  }

  public function sortBy(sort:SortBy) {
    addModifier(QuerySort(sort));
    return this;
  }

  function addModifier(modifier:QueryModifier) {
    hash = null;

    switch type {
      case QueryNone: // noop
      case QueryById(id, modifiers):
        type = QueryById(id, modifiers.concat([modifier]));
      case QueryRange(start, count, modifiers):
        type = QueryRange(start, count, modifiers.concat([modifier]));
      case QueryAll(modifiers):
        type = QueryAll(modifiers.concat([modifier]));
    }
  }

  public function hashCode():Int {
    if (hash != null) return hash;

    function stringifyModifier(modifier:QueryModifier) 
      return switch modifier {
        case QueryWithSiblings: 'with-siblings';
        case QueryChild(name): 'child-$name';
        case QueryExtension(ext): 'ext-$ext';
        case QuerySort(sort): 'sort-$sort';
      }

    var typeStr = switch type {
      case QueryNone: 'none';
      case QueryById(id, modifiers): 
        'by-id-$id' + modifiers.map(stringifyModifier).join('_');
      case QueryAll(modifiers):
        'all' + modifiers.map(stringifyModifier).join('_');
      case QueryRange(first, count, modifiers):
        'range-$first-$count' + modifiers.map(stringifyModifier).join('_');
    }

    hash = (meta.name + typeStr).hash();

    return hash;
  }

  public function getJsonName() {
    return Std.string(hashCode()).withExtension('json');
  }

  public function fetch() {
    return store.find(this);
  }
}
