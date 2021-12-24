package blok.gen2.source;

typedef FormattedFileResult<T:{}> = FileResult & {
  public final formatted:T;
}
