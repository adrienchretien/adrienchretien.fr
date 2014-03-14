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

  # The LibraryPage class is used to render a page with an array of
  # Pattern objects.
  class LibraryPage < Page
    # Additional attributes
    attr_accessor :patterns

    # Initialize a LibraryPage instance.
    #
    # site     - The actual Site instance.
    # name     - The String page name.
    # patterns - The Array of Pattern objects
    #
    # Returns a new LibraryPage instance.
    def initialize(site, name, patterns)
      @site = site
      @dir = ''
      @name = name
      @patterns = patterns

      self.basename = name.gsub(' ', '-')
      self.ext = '.html'
      self.data = {
        'layout' => 'pattern_library',
        'patterns' => patterns,
        'sections' => pattern_attr_hash('section'),
        'title' => name
      }
    end

    # Construct a Hash of Patterns indexed by the specified Pattern attribute.
    #
    # pattern_attr - The String name of the Pattern attribute.
    #
    # Examples
    #
    #   pattern_attr_hash('categories')
    #   # => { 'tech' => [<Pattern A>, <Pattern B>],
    #   #      'ruby' => [<Pattern B>] }
    #
    # Returns the Hash: { attr => patterns } where
    #   attr  - One of the values for the requested attribute.
    #   patterns - The Array of Posts with the given attr value.
    def pattern_attr_hash(pattern_attr)
      # Build a hash map based on the specified pattern attribute ( pattern attr =>
      # array of patterns ) then sort each array in reverse order.
      hash = Hash.new { |hash, key| hash[key] = [] }
      patterns.each { |p|
        p.send(pattern_attr.to_sym).each { |t|
          hash[t] << p
        }
      }
      hash.values.map { |sortme| sortme.sort! { |a, b| b <=> a } }
      hash
    end
  end

  # The PatternLibraryGenerator class generates content related to
  # patterns in the _patterns directory.
  class PatternLibraryGenerator < Generator
    safe true
    # Generates pattern library pages.
    #
    # site - The current Site instance.
    #
    # Returns nothing than an electric wind.
    def generate(site)
      patterns = read_content(site, '', '_patterns', Pattern).sort

      site.pages << LibraryPage.new(site, 'pattern library', patterns)
    end

    # Read all files in <site.source>/<dir>/<name> and create a new object
    # of the given class with each one
    #
    # site  - The current Site instance.
    # dir   - The String path to the parent directory after the site.source.
    # name  - The String filename.
    # klass - The Class used to represent files in the directory
    #
    # Returns an Array of the given class objects
    def read_content(site, dir, magic_dir, klass)
      site.get_entries(dir, magic_dir).map do |entry|
        klass.new(site, site.source, dir, entry) if klass.valid?(entry)
      end.reject do |entry|
        entry.nil?
      end
    end
  end
end
