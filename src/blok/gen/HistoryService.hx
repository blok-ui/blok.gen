package blok.gen;

import blok.core.foundation.routing.History;

@service(fallback = getFallback())
class HistoryService implements Service {
  static var fallback:HistoryService;

  static function getFallback() {
    if (fallback == null) {
      fallback = new HistoryService(
        #if blok.platform.static
          new blok.core.foundation.routing.history.StaticHistory('/')
        #else
          new blok.core.foundation.routing.history.BrowserHistory()
        #end
      ); 
    }
    return fallback;
  }
  
  final history:History;

  public function new(history) {
    this.history = history;
  }

  public inline function getHistory() {
    return history;
  }

  public inline function setLocation(url:String) {
    history.push(url);
  }

  public inline function getLocation() {
    return history.getLocation();
  }
}
