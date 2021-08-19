package blok.gen.data;

import blok.gen.storage.FileResult;
using tink.CoreApi;

typedef ModelPropsParser = (
  file:FileResult,
  data:Dynamic
) -> Promise<{}>;
