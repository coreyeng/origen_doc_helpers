require 'origen_doc_helpers/patdoc/tags'

module OrigenDocHelpers
  module PatDoc
    
    # Represents a single pattern header::PatDoc.
    class PatternHeader
      include OrigenDocHelpers::PatDoc::Tags
      
      attr_reader :tags
      attr_reader :name
      
      attr_reader :path
      attr_reader :relative_path
      attr_reader :root
      
      attr_reader :no_doc
      
      # Attempts to have a tag called any of these will result in errors telling the user these names are reserved.
      # They will need to pick something else.
      RESERVED = [:relative_path, :tags, :name]
      
      def initialize(options={}, &block)
        @file = options[:file]
        @name = options[:name]
        @root = options[:root]
        @path = options[:path]
        @no_doc = options[:no_doc]
        
        if @file && @name.nil?
          @name = File.basename(@file, File.extname(@file))
        end
        
        if @file && @path.nil?
          @path = File.dirname(@file)
        end
        
        # Instantiate all the tags
        @tags = Hash.new
        OrigenDocHelpers::PatDoc::Tags.tags.each do |tag, tag_class|
          tags[tag] = tag_class.new
        end
        
        if block_given?
          yield(self)
          @no_header = false
        else
          @no_header = true
        end
        
        @exception = options[:exception]
        
        @relative_path = Pathname.new(@path.to_s.gsub(@root.to_s, '').gsub(/^\//, ''))
        
        # If we've got a :parent_header (not to be confused with :parent) use that. Otherwise, check if the
        # application has a config.patdoc_parent_header defined. If so, use that.
        if Origen.app.config.respond_to?(:patdoc_parent_header) && !Origen.app.config.patdoc_parent_header.nil?
          puts "MERGING!"
          puts @name
          self.merge!(Origen.app.config.patdoc_parent_header)
        end
      end
      
      def merge(other_header)
      end
      
      def tag_set?(tag)
        unless tag_registered?(tag)
          fail "no tag #{tag} in tag_set?"
        end
        
        tags[tag].tag_set?
      end
      
      def tag_registered?(tag)
        OrigenDocHelpers::PatDoc::Tags.tags.key?(tag)
      end
      
      def merge!(other_header)
        # Since each tag can have its own way of merging, and since tags may be dependent on other tags, we'll merge
        # build a list tags, but merge them in the order that they were registered.
        puts OrigenDocHelpers::PatDoc::Tags.tags
        OrigenDocHelpers::PatDoc::Tags.tags.each do |t, tag|
          puts t
          # If the other header didn't set the tag, then either it will remain unset or we'll use the existing value,
          # so don't need to do anything.
          # Note, using self here just for clarity.
          if other_header.tag_set?(t)
            puts "#{name}: #{self.tag_set?(t)}"
            if self.tag_set?(t)
              puts self.tags[t].respond_to?(:merge)
              self.tags[t].merge!(other_header.tags[t]) if self.tags[t].respond_to?(:merge!)
            else
              self.tags[t].setup(other_header.tags[t].value)
            end
          end
        end
        self.tags
      end
      
      def no_doc?
        @no_doc
      end
      
      def no_header?
        @no_header
      end
      
      def has_header?
        !no_header?
      end
      
      def error_raised?
        !@exception.nil?
      end
      
      def web_ext
        ".md.erb"
      end
      
      def generate(options={})
        filename = "#{name}.md.erb"
        file = Pathname.new(OrigenDocHelpers::PatDoc.pattern_output_dir).join(relative_path)
        unless Dir.exist?(file)
          puts "Creating Directory: #{file}"
          FileUtils.mkdir_p(file)
        end
        file = file.join(filename)
        
        File.open(file, 'w+') do |f|
          f.puts '% render "layouts/basic.html" do'
          f.puts "# Pattern #{name}"
          f.puts
          
          if error_raised?
            # Generate a page showing Ruby error when this file was included.
            message = "When running pattern at <code>#{Pathname.new(@relative_path).join(@name)}</code>. "
            message += "Encountered <code>#{@exception.class}</code> exception with message <code>#{@exception.message}</code>"
            f.puts '<div class="alert alert-danger">'
            f.puts "  <strong>Error!</strong> #{message}"
            f.puts '</div>'
            f.puts
            f.puts '~~~'
            f.puts @exception.inspect
            f.puts 
            
            @exception.backtrace.each do |line|
              f.puts line
            end
            
            f.puts '~~~'
          elsif no_header?
            # Generate a page saying that this file was registered, but there's no header.
            message = "Pattern found at <code>#{Pathname.new(@relative_path).join(@name)}</code> did not have any pattern header! "
            message += "If this pattern does not need one, you can use: \n"
            message += "<code>OrigenDocHelpers::PatDoc.header(no_doc: true)</code>\n"
            message += "To surpress this."
            f.puts '<div class="alert alert-warning">'
            f.puts "  <strong>Warning!</strong> #{message}"
            f.puts '</div>'
          else
            ## Send this off to the generator to handle
            @tags.each do |t, handler|
              #f.puts "#{t}:"
              f.puts handler.to_html
              f.puts
            end
          end
          
          f.puts
          f.puts '% end'
        end
      end
      
      def to_json(options={})
        generate
        @relative_path.join(name).to_json
      end
      
      def header_link
        OrigenDocHelpers::PatDoc.patdoc_server_pattern_offset.join(@relative_path).join(name)
      end
      
      # Returns the output file location
      def header_file(root, options={})
      end
      
    end
  end
end
