package blok.gen.ssr;

import blok.Observable;

enum SsrStatus {
  NotStarted;
  Generating;
  Complete(config:Config);
}

class SsrHooks {
  public final status:Observable<SsrStatus> = new Observable(NotStarted);

  public function new() {}
}
