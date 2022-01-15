import haxe.Timer;
import blok.gen2.cli.NodeConsole;
import blok.gen2.cli.Spinner;

function main() {
  var spinner = new Spinner(new NodeConsole());
  spinner.start();
  // Timer.delay(() -> {
    spinner.stop();
    Sys.exit(0);
  // }, 100000);
}
