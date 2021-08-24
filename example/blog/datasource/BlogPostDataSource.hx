package blog.datasource;

import blok.gen.ssr.formatter.TomlFormatter;
import blok.gen.ssr.formatter.MarkdownFormatter;
import blok.gen.data.Id;
import blok.gen.datasource.FileResult;
import blok.gen.datasource.FileDataSource;
import blok.gen.ssr.SsrConfig;
import blog.data.BlogPost;

using Reflect;
using Lambda;
using haxe.io.Path;
using tink.CoreApi;

// todo: A lot of this could be pulled into a generic DataSource.
class BlogPostDataSource {
  static final formatter = new MarkdownFormatter(new TomlFormatter());

  public static function getPost(config:SsrConfig, id:Id<BlogPost>) {
    return base(config).next(posts -> {
      var post = posts.find(file -> file.meta.name == id);
      var index = posts.indexOf(post);
      var prev = posts[index - 1];
      var next = posts[index + 1];
      return Promise.inParallel([
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
      });
    });
  }

  public static function findPosts(config:SsrConfig, first:Int, count:Int) {
    return base(config).next(files -> {
      var data = files.slice(first, first + count);
      if (data.length <= 0) {
        return new Error(404, 'No data found');
      }
      var startIndex = files.indexOf(data[0]);
      var endIndex = files.indexOf(data[data.length - 1]);

      return Promise
        .inParallel(data.map(decode))
        .next(posts -> Promise.resolve({
          meta: {
            startIndex: startIndex,
            endIndex: endIndex,
            count: posts.length,
            total: files.length
          },
          data: posts
        }));
    });
  }

  static function base(config:SsrConfig) {
    var source = new FileDataSource(config.source);
    return source
      .list('post', path -> path.extension() == 'md')
      .next(posts -> {
        posts.sort((a, b) -> Math.ceil(a.meta.updated.getTime() - b.meta.updated.getTime()));
        posts;
      });
  }

  static function decode(file:FileResult) {
    return formatter
      .parse(file)
      .next(data -> Promise.resolve(new BlogPost({
        id: file.meta.name,
        title: data.data.title,
        content: data.content
      }).toJson()));
  }
}
