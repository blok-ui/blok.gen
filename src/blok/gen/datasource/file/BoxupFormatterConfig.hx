package blok.gen.datasource.file;

import boxup.Generator;
import boxup.Reporter;
import boxup.schema.Schema;

class BoxupFormatterConfig<T> implements Record {
  @prop var schemaPath:String;
  @prop var reporter:Reporter;
  @prop var generatorFactory:(schema:Schema)->Generator<T>;
}