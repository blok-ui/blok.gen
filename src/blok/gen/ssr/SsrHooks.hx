package blok.gen.ssr;

import blok.state.Observable;

enum SsrStatus {
  NotStarted;
  Generating;
  Complete(config:Config);
}

class SsrHooks {
  public final status:Observable<SsrStatus> = new Observable(NotStarted);

  public function new() {}
}
