package blok.gen.cli;

import haxe.Timer;

class Spinner {
  final console:Console;
  final frames = [ "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" ];
  // final frames = [ "◐", "◓", "◑", "◒" ];
  var status:Null<String>;
  var currentFrame = 0;
  var timer:Null<Timer> = null;

  public function new(console) {
    this.console = console;
  }

  public function start() {
    if (timer != null) stop();
    console.hideCursor();
    timer = new Timer(80);
    timer.run = render;
  }

  public function setStatus(status) {
    this.status = status;
  }

  public function render() {
    currentFrame++;
    if (currentFrame > frames.length - 1) {
      currentFrame = 0;
    }
    
    var out = frames[currentFrame];
    if (status != null) {
      out += ' [ $status ]';
    } 
    
    console.update(out);
  }

  public function stop() {
    if (timer == null) return;
    console.clear();
    console.showCursor();
    currentFrame = 0;
    timer.stop();
    timer = null;
  }

  public function isRunning() {
    return timer != null;
  }
}
