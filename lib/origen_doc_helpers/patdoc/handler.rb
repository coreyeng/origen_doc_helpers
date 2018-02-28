module OrigenDocHelpers
  module PatDoc
    require 'json'
    # Handles a collection of pattern header objects, when/where they are generated, and how they are organized within
    # the web page.
    class Handler
      
      def initialize(*args)
        # Pluck the last value from the arguments. The only accepted arguments to this are Strings and a Hash,
        # so if its a Hash, assume its the options.
        options = (args.pop if args.last.is_a?(Hash)) || {}
        
        #if args.empty?
          #puts "HI"
          paths = [Pathname.new("#{Origen.app.root}/pattern")]
        #else
          # Leftover arguments are the files/directories to run PatDoc on, instead of the default pattern directory.
        #  paths = args.map do |file_or_path|
            
        #  end
          #files = 
        #end
        
        # Based off the paths, find all given files.
        #files = []
        @root = Pathname.new("#{Origen.app.root}/pattern")
        
        #print_listing_files
        #JSON.pretty_print(files)
        #files.pp
        #pp files
        #paths.each do |p|
        #  puts p
        #  files = Dir.glob(p.join('**/*.rb'))
        #end
        #puts files
        
        #patterns = {}
        #files.each do |f|
        #  
        #end
      end
      
      # Goes through the paths/files given and tries to create the pattern headers.
      # The pattern headers will be stored in the Hash along with the file that it came from.
      def build_filelist(path, options={})
        children = Pathname.new(path).children
        return_hash = {}
        children.each do |child|
          if child.directory?
            return_hash[child] = build_filelist(child, options)
          elsif child.extname == '.rb'
            #puts child
            begin
              OrigenDocHelpers::PatDoc._reset_header_array
              require child
              
              # collect any of the pattern docs that were just added from this file.
              if OrigenDocHelpers::PatDoc._header_count > 0
                # Note, this will shallow copy the array, which is actually what we want.
                # We don't need multiple copies of the pattern header floating around.
                return_hash[child] = OrigenDocHelpers::PatDoc._header_array.clone
              else
                # Empty pattern header (i.e., no header found)
                # Note that this is different than an empty block
                  #puts child
                return_hash[child] = PatDoc.header(
                  no_header: true,
                  file: child,
                  root: @root,
                  name: File.basename(child, File.extname(child)),
                  path: child.dirname,
                )
                OrigenDocHelpers::PatDoc._reset_header_array
              end
            rescue Exception => e
              #return_hash[child] = e
              return_hash[child] = PatDoc.header(
                file: child,
                exception: e,
                root: @root,
                name: File.basename(child, File.extname(child)),
                path: child.dirname,
              )
              OrigenDocHelpers::PatDoc._reset_header_array
              raise e
            end
          end
        end
        @files = return_hash
        
        return_hash
      end
      
      # This will print the list of pattern files found and the status of the PadDoc header(s) within it.
      # Note: at this point, this is only checking files. This isn't actually pointing to where the
      # headers will end up.
      # This is used more for debug/development. This allows the user to see which files PatDoc is seeing and if/which
      # headers it was able to extract from it.
      def pretty_print(struct)
        def print_hash(hash, options={})
          options[:spacing] = options[:spacing] || 0
          hash.each do |key, val|
            if val.is_a?(Hash) || val.is_a?(PatternGroup)
              # Subdirectory. Go through the subdirectory
              puts (' '*options[:spacing]) + key.to_s
              opts = options.clone
              opts[:spacing] += 2
              print_hash(val, opts)
            else
              if val.nil?
                # There were no headers in this. Make it yellow.
                puts ((' '*options[:spacing]) + key.to_s).yellow
              elsif val.is_a?(Exception)
                # Errors were thrown. Make this red.
                puts ((' '*options[:spacing]) + key.to_s).red
              elsif val.is_a?(Array)
                # Headers were found.
                puts ((' '*options[:spacing]) + key.to_s + " (Found #{val.size} header(s))").green
              elsif val.is_a?(PatternHeader) && val.error_raised?
                puts ((' '*options[:spacing]) + key.to_s).red
              elsif val.is_a?(PatternHeader) && val.has_header?
                puts ((' '*options[:spacing]) + key.to_s).green
              elsif val.is_a?(PatternHeader) && val.no_header?
                puts ((' '*options[:spacing]) + key.to_s).yellow
              else
                puts ((' '*options[:spacing]) + key.to_s + ": Unexpected class: #{val.class}").red
              end
            end
          end
        end
        
        print_hash(struct)
      end
      
      # With the @filelist showing all the filenames and pointing to its relevant headers, build the actual structure in
      # terms of pattern names and modules instead of filenames/paths.
      # NOTE: the 'root' of the module will be the first level of the filelist.
      def build_patdoc_structure(filelist, options={})
        def build_module(name, group, options={})
          root_path = options[:root_path] || ''
          puts root_path
          relative_path = options[:relative_path] || ''
          puts relative_path.to_s.cyan
          struct = OrigenDocHelpers::PatDoc::PatternGroup.new(name, relative_path: relative_path)
          
          group.each do |name, headers|
            root = name.each_filename.to_a.last
            relative_path = Pathname.new((name.each_filename.to_a - root_path.each_filename.to_a).join('/'))
            if headers.nil? || headers.is_a?(Exception) || (headers.is_a?(PatternHeader) && headers.no_header?)
              # Since these were compiled and either were empty or raised an exception, we will still generate
              # a webpage complaining about this.
              # It is assumed this is an error by the user and these should be fixed. Unless explicitly skipped,
              # we will add a webpage to them.
              # In this case, we will treat these as patterns, not modules.
              #struct[name.each_filename.to_a.last] = headers
              struct[headers.name] = headers
            elsif headers.is_a?(Array)
              # Set of headers here. Exact pattern names and set it to the header object.
              headers.each do |h|
                # If the header is not be documented, skip it.
                unless h.no_doc?
                  # If this name conflicts with another, complain about it.
                  struct[h.name] = h
                  #struct[Pathname.new(h.name).each_filename.to_a.last] = h
                end
              end
            elsif headers.is_a?(Hash)
              # This is a submodule. Shift the context over and rebuild the context.
              opts = options.clone
              opts[:relative_path] = relative_path
              struct[root] = build_module(root, headers, opts)
            end
          end
          @headers = struct
          struct
        end
=begin
        def build_module(mod, options={})
          struct = {}
          mod.each do |name, headers|
            root = name.each_filename.to_a.last
            if headers.nil? || headers.is_a?(Exception)
              # Since these were compiled and either were empty or raised an exception, we will still generate
              # a webpage complaining about this.
              # It is assumed this is an error by the user and these should be fixed. Unless explicitly skipped,
              # we will add a webpage to them.
              # In this case, we will treat these as patterns, not modules.
              struct[name.each_filename.to_a.last] = headers
            elsif headers.is_a?(Array)
              # Set of headers here. Exact pattern names and set it to the header object.
              headers.each do |h|
                struct[Pathname.new(h.name).each_filename.to_a.last] = h
              end
            elsif headers.is_a?(Hash)
              # This is a submodule. Shift the context over and rebuild the context.
              struct[root.to_sym] = build_module(headers, options)
            end
          end
          struct
        end
=end        
        #struct = {}
        #filelist.each do |k, v|
          # This first level is separate because the roots might not be consistent.
          # There's nothing stopping the user from having 3 vastly different directories here.
          # It is assumed in build_module that the submodules are relative to the root.
        #  root = k.each_filename.to_a
        #  struct[root.last] = build_module(v, k)
        #end
        #struct
        build_module(:TOP, filelist, root_path: @root)
      end
      
      # This will print the final PatDoc structure. This is decoupled from the actual filenames in the paths/files
      # and will be based on the :name in the PatDoc::Header object.
      # This is also in terms of modules/patter names, instead of paths/files, as stated, and as pretty_print_file_structure is.
      def pretty_print_patdoc_structure
        def print_struct(struct, options={})
          struct.each do |key, val|
            if key.is_a?(Hash)
              # This is a module. Need to print the module.
              print_struct(val, opts)
            else
            end
          end
        end
        
        print_struct(@headers)
      end
      
      def show_patdoc(options={})
        #pretty_print_patdoc_structure
        pretty_print(@headers)
      end
      
      def show_status(options={})
        puts "Showing File Statuses..."
        
        pretty_print(@files)
        
        puts 'Key:'
        puts ' green: PatDoc header(s) found and compiled successfully'.green
        puts ' yellow: Warning(s) was/were generated'.yellow
        puts ' red: An exception was raised'.red
        puts 'See here for additional details: ...'
      end
      
      # Prints the sitemap file.
      # The sitemap file is a JSON structure containing a combination of the headers and their locations.
      def print_sitemap(options={})
        # The headers are organized as name => PatternHeader/GroupHeader right now. Can't represent all that in a
        # sitemap, but all we need are the filenames, or nil (NULL, in the sitemap) if nothing was found.
        # Patterns themselves will just be 'pattern' => 'filename'
        # Pattern Groups will be 'pattern_group' => {'content_file' => 'filename', 'patterns' => {Patterns}, 'groups' => {Groups}}
        File.open(OrigenDocHelpers::PatDoc.sitemap, 'w+') do |f|
          f.write(JSON.pretty_generate(@headers))
        end
      end
=begin      
      #
      def print_listing_files(options={})
        def print_listing(contents, options={})
          contents.each do |name, contents|
            if contents.is_a?(Hash)
              dir = OrigenDocHelpers::PatDoc.patdoc_dir.join(options[:current_path]).join(name.to_s)
              unless Dir.exist?(dir)
                FileUtils.mkdir_p(dir)
              end
              
              filename = dir.join("_listing_#{name}.md.erb")
              puts filename
              
              File.open(filename, 'w+') do |f|
                # For these file, we're not relying on nanoc to generate the listing. So, we don't have to worry
                # about creating the tabs (at least not yet)
                f.puts '% render "layouts/basic.html" do'
                f.puts "# Listing For Module #{name}"
                f.puts
                f.puts '<ul>'
                
                contents.each do |n, c|
                  f.puts "<li>#{n}</li>"
                end
                
                f.puts '</ul>'
                f.puts '% end'
              end
              
            end
            #File.open(OrigenDocHelpers::PatDoc.patdoc_dir.join(options[:current_path].join(name), 'w+') do |f|
            #end
          end
        end
        
        options[:current_path] = ""
        print_listing(@headers, options)
      end
=end      
      def root
        @root
      end
      
      # Prints the sitemap
      def print_patterns_sitemap(options={})
      end
      
      def print_navbar(options={})
      end
    end
  end
end
