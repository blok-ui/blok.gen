package example.datasource;

import blok.Service;
import blok.gen.data.Id;
import blok.gen.datasource.FormattedFileResult;
import blok.gen.datasource.FormattedDataSource;
import example.data.BlogPost;

using Reflect;
using Lambda;
using haxe.io.Path;
using tink.CoreApi;

@service(fallback = new BlogPostDataSource())
class BlogPostDataSource implements Service {
  @use var source:FormattedDataSource;

  public function new() {}

  public function getPost(id:Id<BlogPost>) {
    return base().next(posts -> {
      var post = posts.find(file -> file.meta.name == id);
      var index = posts.indexOf(post);
      var prev = posts[index - 1];
      var next = posts[index + 1];
      
      return Promise.resolve({
        meta: {
          prev: prev == null ? null : decode(prev),
          next: next == null ? null : decode(next)
        },
        data: decode(post)
      });
    });
  }

  public function findPosts(first:Int, count:Int) {
    return base().next(files -> {
      var data = files.slice(first, first + count);
      if (data.length <= 0) {
        return Promise.reject(new Error(404, 'No data found'));
      }

      var startIndex = files.indexOf(data[0]);
      var endIndex = files.indexOf(data[data.length - 1]);
      var posts = data.map(decode);

      return Promise.resolve({
        meta: {
          startIndex: startIndex,
          endIndex: endIndex,
          count: posts.length,
          total: files.length
        },
        data: posts
      });
    });
  }

  function base():Promise<Array<FormattedFileResult<{}>>> {
    return source
      .list('post', path -> path.extension() == 'md')
      .next(posts -> {
        posts.sort((a, b) -> Math.ceil(a.meta.updated.getTime() - b.meta.updated.getTime()));
        posts;
      });
  }

  function decode(file:FormattedFileResult<{}>):{} {
    return new BlogPost({
      id: file.meta.name,
      title: (file.formatted.field('data'):{}).field('title'),
      content: (file.formatted.field('content'):String)
    }).toJson();
  }
}
