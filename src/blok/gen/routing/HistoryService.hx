package blok.gen.routing;

import blok.context.Service;
import blok.foundation.routing.History;

@service(fallback = new HistoryService(
  #if blok.platform.static
    new blok.foundation.routing.history.StaticHistory('/')
  #else
    new blok.foundation.routing.history.BrowserHistory()
  #end
))
class HistoryService implements Service { 
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
