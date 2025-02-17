module Document
  # File に関する情報の抽象
  class Article
    attr_reader :path, :article

    def initialize(path)
      @path = path
      @text = File.read(path)
    end

    # "./blog.jxck.io/entries/2016-01-27"
    def dir
      File.dirname(@path)
    end

    # "new-blog-start"
    def name
      File.basename(@path, ".*")
    end

    # "blog.jxck.io"
    def host
      dir.split("/")[1]
    end

    # "entries/2016-01-27"
    def baseurl
      dir.split("/")[2..4].join("/").to_s
    end

    # "entries/2016-01-27/new-blog-start.html"
    def relative
      "#{baseurl}/#{name}.html"
    end

    # "/entries/2016-01-27/new-blog-start.html"
    def url
      "/#{baseurl}/#{name}.html"
    end

    # "https://blog.jxck.io/entries/2016-01-27/new-blog-start.html"
    def canonical
      "https://#{host}#{url}"
    end

    def title
      hsc @text.match(/^# \[.*\] (.*)/)[1]
    end

    def toc
      @toc.map{|toc|
        href  = "##{toc[:id]}"
        value = "#{'#' * toc[:level]} #{toc[:value]}"
        [href, value]
      }
    end

    # AST parse する markdown の body
    # 前処理が必要な場合は継承する
    def body
      @text
    end

    def build(format) # HTML/AMP
      # parse ast
      ast = MD2Indesign::Markdown::AST.new(body)
      # DEBUG: pp ast.ast

      # traverse
      traverser = MD2Indesign::Markdown::Traverser.new(format, dir)
      article   = traverser.start(ast.ast)
      @toc      = format.toc
      @article  = article
    end

    def target_path
      "#{dir}/#{name}.html"
    end

    def to_s
      path
    end

    def <=>(other)
      path <=> other.path
    end

    protected

    # remove markdown link notation
    # [aaa](http://example.com) -> aaa
    # <http://example.com> -> http://example.com
    def unlink(str)
      str.gsub(/\[(.*?)\]\(.*?\)/, '\1').gsub(/<(http.*?)>/, '\1')
    end
  end
end
