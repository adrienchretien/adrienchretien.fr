module Jekyll

  class LibraryPage < Page
    def initialize(site, name, patterns)
      @site = site
      @dir = ''
      @name = name

      self.basename = name.gsub(' ', '-')
      self.ext = '.html'
      self.data = {
        'layout' => 'pattern_library',
        'patterns' => patterns,
        'name' => name
      }
    end
  end

  class PatternLibraryGenerator < Generator

    # Generate pattern library pages.
    #
    # site - The current Site instance.
    #
    # Returns nothing than an electric wind.
    def generate(site)
      patterns = read_content(site, '', '_patterns', Pattern).sort!

      site.pages << LibraryPage.new(site, 'patchwork', patterns)
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