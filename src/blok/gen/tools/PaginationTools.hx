package blok.gen.tools;

// This is probably a horrible way to do this :V
class PaginationTools {  
  public static function paginate(totalItems:Int, perPage:Int) {
    var total = Math.ceil(totalItems / perPage);
    return total;
  }

  public static function toPageNumber(index:Int, perPage:Int) {
    return Math.ceil((index + 1) / perPage);
  }

  public static function toIndex(page:Int, perPage:Int) {
    return (page - 1) * perPage;
  }
}
