package example.datasource;

import blok.gen.AsyncData;
import blok.Service;
import blok.gen.data.Id;
import blok.gen.datasource.FileResult;
import blok.gen.datasource.FileDataSource;
import blok.gen.datasource.file.TomlFormatter;
import blok.gen.datasource.file.MarkdownFormatter;
import example.data.BlogPost;

using Reflect;
using Lambda;
using haxe.io.Path;
using tink.CoreApi;

@service(isOptional)
class BlogPostDataSource implements Service {
  final formatter = new MarkdownFormatter(new TomlFormatter());
  @use var source:FileDataSource;

  public function new() {}

  public function getPost(id:Id<BlogPost>) {
    return base().flatMap(posts -> {
      var post = posts.find(file -> file.meta.name == id);
      var index = posts.indexOf(post);
      var prev = posts[index - 1];
      var next = posts[index + 1];
      
      return Loading(Promise.inParallel([
        prev == null ? Promise.resolve(null) : decode(prev),
        decode(post),
        next == null ? Promise.resolve(null) : decode(next)
      ]).next(posts -> {
        Promise.resolve({
          meta: {
            prev: posts[0],
            next: posts[2]
          },
          data: posts[1]
        });
      }));
    });
  }

  public function findPosts(first:Int, count:Int) {
    return base().flatMap(files -> {
      var data = files.slice(first, first + count);
      if (data.length <= 0) {
        return Failed(new Error(404, 'No data found'));
      }

      var startIndex = files.indexOf(data[0]);
      var endIndex = files.indexOf(data[data.length - 1]);

      return Loading(Promise
        .inParallel(data.map(decode))
        .next(posts -> Promise.resolve({
          meta: {
            startIndex: startIndex,
            endIndex: endIndex,
            count: posts.length,
            total: files.length
          },
          data: posts
        })));
    });
  }

  function base():AsyncData<Array<FileResult>> {
    return source
      .list('post', path -> path.extension() == 'md')
      .map(posts -> {
        posts.sort((a, b) -> Math.ceil(a.meta.updated.getTime() - b.meta.updated.getTime()));
        posts;
      });
  }

  function decode(file:FileResult) {
    return formatter
      .parse(file)
      .next(data -> Promise.resolve(new BlogPost({
        id: file.meta.name,
        title: data.data.title,
        content: data.content
      }).toJson()));
  }
}
