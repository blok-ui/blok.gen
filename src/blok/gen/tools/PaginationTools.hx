package blok.gen.tools;

class PaginationTools {
  public static function paginate<T>(items:Array<T>, perPage:Int) {
    function slice(page:Int) {
      var offset = (page - 1) * perPage;
      return items.slice(offset, offset + perPage);
    }
    var total = Math.ceil(items.length / perPage);
    var page = 1;
    return [ while (page <= total) {
      var data = slice(page);
      var num = page;
      page++;
      {
        page: num,
        totalPages: total,
        data: data
      };
    } ];
  }
}
