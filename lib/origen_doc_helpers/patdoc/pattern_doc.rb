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
      
      # Attempts to have a tag called any of these will result in errors telling the user these names are reserved.
      # They will need to pick something else.
      RESERVED = [:relative_path, :tags, :name]
      
      def initialize(options={}, &block)
        @file = options[:file]
        
        @name = options[:name]
        @root = options[:root]
        @path = options[:path]
        
        if @file
          @name = File.basename(@file, File.extname(@file))
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
            
          elsif no_header?
            # Generate a page saying that this file was registered, but there's no header.
            
          else
            # Send this off to the generator to handle
          end
          
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
