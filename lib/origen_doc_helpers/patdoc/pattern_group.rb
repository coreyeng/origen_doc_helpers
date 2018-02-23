module OrigenDocHelpers
  module PatDoc
  
    class PatternGroup
    
      attr_reader :groups
      attr_reader :patterns
      attr_reader :relative_path
      attr_reader :name
      attr_reader :output_root
      
      def initialize(name, options={})
        @name = name
        @groups = {}
        @patterns = {}
        
        @output_root = OrigenDocHelpers::PatDoc.pattern_output_dir
        @patdoc_server_offset = OrigenDocHelpers::PatDoc.patdoc_server_offset
        @relative_path = options[:relative_path] || ''
      end
      
      def add_group(name, pattern_group)
        groups[name] = pattern_group
      end
      
      #def output(options={})
        
      #end
      
      def add_pattern(name, pattern_header)
        patterns[name] = pattern_header
      end
      
      def [](name)
      end
      
      def []=(name, val)
        if val.is_a?(PatternGroup)
          groups[name] = val
        elsif val.is_a?(PatternHeader) || val.nil? || val.is_a?(Exception)
          patterns[name] = val
        else
          fail "Added class: #{val.class} to pattern group"
        end
      end
      
      def each(&block)
        groups.each(&block)
        patterns.each(&block)
      end
      
      def each_pattern(&block)
        patterns.each(&block)
      end
      
      def each_group(&block)
        patterns.each(&block)
      end
      
      def has_patterns?
        !patterns.empty?
      end
      
      def has_groups?
        !groups.empty?
      end
      
      def generate_groups_listing(_group, options={})
        html = []
        
        collapse_id = "#{_group.name}_#{Random.rand(1..2**16)}"
  	    html << '<div class="panel-group">'
  	    html << '  <div class="panel panel-default">'
  	    html << '    <div class="panel-heading">'
  	    html << '      <h4 class="panel-title">'
  	    html << '        <a data-toggle="collapse" href="#group_' + collapse_id + '">' + _group.name.to_s + '</a>'
  	    html << '      </h4>'
  	    html << '    </div>'
        
  	    html << '    <div id="group_' + collapse_id + '" class="panel-collapse collapse in">'
        html << '    <ul class="list-group">'
        
        if _group.has_groups?
          _group.groups.each do |n, g|
            #html << "<li class='list-group-item'>#{n}</li>"
            html << '<li class="list-group-item">'
            html += generate_groups_listing(g, options)
            html << '</li>'
          end
        end
        
        if _group.has_patterns?
          _group.patterns.each do |n, p|
            html << "      <li class='list-group-item'><a href=\"<%= path \"#{p.header_link}\" %>\">#{n}</a></li>"
          end
        end
        
        html << '    </ul>'
  	    html << '    </div>'
  	    html << '  </div>'
  	    html << '</div>'
  	            
        html
      end
      
      #def generate_pattern_listing(_pattern, options={})
      #  html = []
      #  patterns.each do |name, pattern|
      #    html << "<li class='list-group-item'>#{name}</li>"
      #  end
      #  html.join("\n")
      #end
      
      def listing_file
        filename = "listing_#{name}.md.erb"
        file = Pathname.new(output_root).join(relative_path)
        unless Dir.exist?(file)
          puts "Creating Directory: #{file}"
          FileUtils.mkdir_p(file)
        end
        
        file = file.join(filename)
        File.open(file, 'w+') do |f|
          f.puts '% render "layouts/basic.html" do'
          f.puts "# Listing For Group #{name}"
          f.puts
          
          # Create a collapsable group.
          
          f.puts generate_groups_listing(self).join("\n")
          #f.puts generate_pattern_listing(patterns)
    	    
          f.puts '% end'
        end
        
        # The actual file name that we want in the sitemap should actually be a relative link to the
        # root of the pattern_output_dir.
        #Pathname.new(relative_path).join(filename)
        Pathname.new(relative_path).join("listing_#{name}")
      end
      
      # The JSON structure of a pattern group is:
      # {
      #   'content_file' => 'content filename',
      #   'patterns' => { Patterns },
      #   'groups' => { Groups },
      # }
      def to_json(options={})
        retn = {}
        
        retn['root'] = OrigenDocHelpers::PatDoc.patdoc_server_pattern_offset
        retn['listing_file'] = listing_file
        retn['patterns'] = patterns
        retn['groups'] = groups
        
        JSON.pretty_generate(retn, options)
      end
      
    end
    
  end
end
