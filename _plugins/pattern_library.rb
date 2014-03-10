# encoding: UTF-8

module Jekyll
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
    # Generates pattern library pages.
    #
    # site - The current Site instance.
    #
    # Returns nothing than an electric wind.
    def generate(site)
      patterns = read_content(site, '', '_patterns', Pattern).sort

      # site.pages << LibraryPage.new(site, 'patchwork', patterns)
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
