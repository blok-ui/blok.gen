package blok.gen.cli;

import js.Node.process;

class NodeConsole implements Console {
  public function new() {}

  public function write(content:String):Void {
    process.stdout.write(content);
  }

  public function update(content:String) {
    clear(content);
  }

  public function clear(replaceWith:String = '') {
    // note: using ANSI CSI
    process.stdout.write('\033[2K\033[200D' + replaceWith);
  }

  public function hideCursor() {
    process.stdout.write('\033[?25l');
  }

  public function showCursor() {
    process.stdout.write('\033[?25h');
  }
}
