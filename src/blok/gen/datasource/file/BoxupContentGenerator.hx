package blok.gen.datasource.file;

import boxup.Position;
import boxup.Error;
import boxup.Node;
import boxup.Result;
import blok.gen.data.ContentGenerator;
import blok.gen.data.Content;

class BoxupContentGenerator extends BoxupGenerator<Array<Content>> {
  public function generate(nodes:Array<Node>):Result<Array<Content>> {
    return try {
      Ok(ContentGenerator.ofBoxup(schema, nodes));
    } catch (e) {
      Fail(new Error(e.message, Position.unknown()));
    }
  }
}
