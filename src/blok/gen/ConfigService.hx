package blok.gen;

@service(fallback = throw 'No config service found')
class ConfigService implements Service {
  final config:Config;

  public function new(config) {
    this.config = config;
  }

  public inline function getConfig() {
    return config;
  }
}
