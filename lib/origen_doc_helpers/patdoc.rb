module OrigenDocHelpers
  module PatDoc
  
    # Creates a new handler
    def self.handler(*args)
      @handler || handler!(args)
    end
    
    # Forces creation of a new handler
    def self.handler!(*args)
      @handler = OrigenDocHelpers::PatDoc::Handler.new(args)
      @handler
    end
    
    def self.header(options={}, &block)
      options = {
        file: caller[0].split(':').first
        #root: self.handler.root,
      }.merge(options)
      options[:root] = self.handler.root unless options.key?(:root)
      #exit!
      # Create a new pattern header object and add it.
      last_header = OrigenDocHelpers::PatDoc::PatternHeader.new(options, &block)
      @headers << last_header
      last_header
    end
    
    def self._reset_header_array
      @headers = Array.new
    end
    
    def self._header_array
      @headers
    end
    
    def self._header_count
      @headers.size
    end
    
    # Returns the last header that was parsed.
    def _last_header
      @last_header
    end
    
    def self.patdoc_dir(options={})
      dir = Pathname.new(Origen.app.root).join("templates/web").join(patdoc_server_offset)
      
      # create the directory if it doesn't exist
      FileUtils.mkdir_p(dir.to_s) unless Dir.exist?(dir.to_s)
      
      # return the sitemap
      dir
    end
    
    def self.patdoc_server_pattern_offset(options={})
      Pathname.new("patdocgen").join('patterns')
    end
    
    def self.pattern_source_dir(options={})
      Pathname.new(Origen.app.root).join('pattern')
    end
    
    def self.patdoc_server_offset(options={})
      Pathname.new("patdocgen")
    end
    
    def self.pattern_output_dir(options={})
      patterns = patdoc_dir.join('patterns')
      
      # create the directory if it doesn't exist
      FileUtils.mkdir_p(patterns.to_s) unless Dir.exist?(patterns.to_s)
      
      # return the pattern output dir
      patterns
    end
    
    def self.sitemap(options={})
      patdoc_dir.join('sitemap.json')
    end
    
    def self.read_sitemap(options={})
      JSON.parse(File.read(sitemap.to_s))
    end
    
    def self.patdoc_generating?
      @patdoc_generating ||= false
    end
    
    def self.start_patdoc_generating
      @patdoc_generating = true
    end
    
    def self.stop_patdoc_generating
      @patdoc_generating = false
    end
  end
end
