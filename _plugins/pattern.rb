# encoding: UTF-8

module Jekyll
  # The Pattern class is used to render patterns.
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
    attr_accessor :id, :markup_escaped, :section, :usage

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

      self.markup_escaped = CGI.escapeHTML(content)
      self.id = data.key?('id') ? data['id'].to_s : name.match(MATCHER)[1]
      self.section = data.key?('section') ? [data['section'].to_s] : []
      self.usage = data.key?('usage') ? data['usage'].to_s : nil
    end

    # Get the full path to the directory containing the pattern files
    def containing_dir(source, dir)
      File.join(source, dir, '_patterns')
    end

    # Add any necessary layouts to this pattern.
    #
    # layouts      - A Hash of {'name' => 'layout'}.
    # site_payload - The site payload hash.
    #
    # Returns nothing.
    def render(layouts, site_payload)
      # construct payload
      payload = site_payload
      payload = payload.merge('page' => to_liquid)

      do_layout(payload, layouts)
    end

    # Obtain destination path.
    #
    # dest - The String path to the destination dir.
    #
    # Returns destination file path String.
    def destination(dest)
      # The url needs to be unescaped in order to preserve the correct filename
      path = Jekyll.sanitized_path(dest, CGI.unescape(url))
      path = File.join(path, 'index.html') if path[/\.html$/].nil?
      path
    end

    # Merge Pattern attributes to the data hash used by Liquid.
    def to_liquid
      data.deep_merge({
        'id' => id,
        'markup_escaped' => markup_escaped,
        'markup' => content,
        'section' => section
      })
    end

    # Compares Pattern objects. First compares the Pattern id. If the ids are
    # equal, it compares the Pattern filename.
    #
    # other - The other Pattern we are comparing to.
    #
    # Returns -1, 0, 1
    def <=>(other)
      cmp = id <=> other.id
      if 0 == cmp
        cmp = name <=> other.name
      end
      cmp
    end

    # Returns the shorthand String identifier of this Pattern.
    def inspect
      "<Pattern: #{id}>"
    end
  end
end
