package blok.gen;

import blok.gen.DataSource;

using Type;

@service(fallback = new DataSourceService([]))
class DataSourceService implements Service {
  final sources:Map<String, DataSource>;

  public function new(sources:Array<DataSource>) {
    this.sources = [ for (cls in sources)
      cls.getClass().getClassName() => cls
    ];
  }

  public function getDataSource<T:DataSource>(type:Class<T>):Null<T> {
    return cast sources.get(type.getClassName());
  }
}
