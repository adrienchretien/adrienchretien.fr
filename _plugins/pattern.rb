module Jekyll

  class Pattern
    include Comparable
    include Convertible

    # Valid pattern name regex.
    MATCHER = /^(\w[\w-]*)\.[^.]+$/

    # Pattern name validator. Pattern filenames must be like:
    # my-pattern.html
    #
    # name       - The String filename of the pattern file.
    #
    # Returns true if valid, false if not.
    def self.valid?(name)
      name =~ MATCHER
    end

    attr_accessor :site
    attr_accessor :data, :content, :output, :ext
    attr_accessor :code, :id, :usage

    attr_reader :name

    # Initialize this Pattern instance.
    #
    # site       - The Site.
    # base       - The String path to the dir containing the pattern file.
    # name       - The String filename of the pattern file.
    #
    # Returns the new Pattern.
    def initialize(site, source, dir, name)
      @site = site
      @dir = dir
      @base = containing_dir(source, dir)
      @name = name

      read_yaml(@base, name)

      self.code = CGI.escapeHTML(self.content)
      
      if self.data.has_key?('id')
        self.id = self.data['id'].to_s
      else
        self.id = name.match(MATCHER)[1]
      end
      
      if self.data.has_key?('usage')
        self.usage = self.data['usage'].to_s
      end
    end

    # Get the full path to the directory containing the pattern files
    def containing_dir(source, dir)
      return File.join(source, dir, '_patterns')
    end

    # Add any necessary layouts to this pattern.
    #
    # layouts      - A Hash of {"name" => "layout"}.
    # site_payload - The site payload hash.
    #
    # Returns nothing.
    def render(layouts, site_payload)
      # construct payload
      payload = site_payload

      do_layout(payload.merge({"page" => to_liquid}), layouts)
    end

    # Obtain destination path.
    #
    # dest - The String path to the destination dir.
    #
    # Returns destination file path String.
    def destination(dest)
      # The url needs to be unescaped in order to preserve the correct filename
      path = Jekyll.sanitized_path(dest, CGI.unescape(url))
      path = File.join(path, "index.html") if path[/\.html$/].nil?
      path
    end

    # Merge Pattern's attributes to Liquid data associated to the object
    def to_liquid
      self.data.deep_merge({
        "code" => self.code,
        "content" => self.content,
        "id" => self.id,
        "usage" => self.usage
      })
    end

    # Compares Pattern objects. First compares the Pattern id. If the ids are
    # equal, it compares the Pattern filename.
    #
    # other - The other Pattern we are comparing to.
    #
    # Returns -1, 0, 1
    def <=>(other)
      cmp = self.id <=> other.id
      if 0 == cmp
       cmp = self.name <=> other.name
      end
      return cmp
    end
  end
end