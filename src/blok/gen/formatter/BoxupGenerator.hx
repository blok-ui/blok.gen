package blok.gen.formatter;

import boxup.Node;
import boxup.Result;
import boxup.schema.Schema;
import boxup.Generator;

abstract class BoxupGenerator<T> implements Generator<T> {
  final schema:Schema;

  public function new(schema) {
    this.schema = schema;
  }

  abstract public function generate(nodes:Array<Node>):Result<T>;
}
