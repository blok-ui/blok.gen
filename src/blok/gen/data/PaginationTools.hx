package blok.gen.data;

// This is probably a horrible way to do this :V
class PaginationTools {  
  public static function paginate(totalItems:Int, perPage:Int) {
    if (perPage == null || perPage == 0) return totalItems;
    var total = Math.ceil(totalItems / perPage);
    return total;
  }

  public static function toPageNumber(index:Int, perPage:Int) {
    if (perPage == null || perPage == 0) return index + 1;
    return Math.ceil((index + 1) / perPage);
  }

  public static function toIndex(page:Int, perPage:Int) {
    return (page - 1) * perPage;
  }
}
