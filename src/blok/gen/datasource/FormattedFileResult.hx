package blok.gen.datasource;

typedef FormattedFileResult<T:{}> = FileResult & {
  public final formatted:T;
}
