package blok.gen2.cli;

class Display {
  final console:Console;
  final spinner:Spinner;
  #if debug
    final log:Array<String> = [];
    final start = Date.now().getTime();
  #end

  public function new(console) {
    this.console = console;
    spinner = new Spinner(this.console);
  }

  public function setStatus(status) {
    #if debug
      var stamp = (Date.now().getTime() - start) / 1000 + 's';
      log.push(stamp + ' : ' + status);
    #end
    spinner.setStatus(status);
  }

  public function write(message) {
    var shouldRestart = false;
    if (spinner.isRunning()) {
      shouldRestart = true;
      spinner.stop();
      console.clear();
    }
    console.write(message + '\n');
    if (shouldRestart) {
      spinner.start();
    }
  }

  public function work() {
    spinner.start();
  }

  public function error(message:String) {
    spinner.stop();
    console.write(' X ' + message + '\n');
    #if debug printLog(); #end
  }

  public function success(message:String) {
    spinner.stop();
    console.write(' ✓ ' + message + '\n');
    #if debug printLog(); #end
  }

  #if debug
    function printLog() {
      #if !blok.gen.debug.no_logging
        console.write('\nEvent log:\n\n');
        for (item in log) {
          console.write(item + '\n');
        }
      #end
    }
  #end
}
