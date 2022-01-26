package blok.gen.formatter;

import boxup.Position;
import boxup.Error;
import boxup.Node;
import boxup.Result;
import blok.gen.content.ContentGenerator;
import blok.gen.content.Content;

class BoxupContentGenerator extends BoxupGenerator<Array<Content>> {
  public function generate(nodes:Array<Node>):Result<Array<Content>> {
    return try {
      Ok(ContentGenerator.ofBoxup(schema, nodes));
    } catch (e) {
      Fail(new Error(e.message, Position.unknown()));
    }
  }
}
