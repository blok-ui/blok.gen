package blok.gen.source;

typedef FormattedFileResult<T:{}> = FileResult & {
  public final formatted:T;
}
