import haxe.Timer;
import blok.gen.cli.NodeConsole;
import blok.gen.cli.Spinner;

function main() {
  var spinner = new Spinner(new NodeConsole());
  spinner.start();
  // Timer.delay(() -> {
    spinner.stop();
    Sys.exit(0);
  // }, 100000);
}
