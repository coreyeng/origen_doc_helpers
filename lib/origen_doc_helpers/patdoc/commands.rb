module OrigenDocHelpers
  module PatDoc
  module Commands
    require 'optparse'
    
    def self.generate
      options = {}
      OptionParser.new do |opts|
        opts.on('--tags', 'Show the currently registered tags') do |o|
          options[:show_tags] = true
        end
        opts.on('--find', 'Runs PatDoc but only lists the files found and their header state') do |o|
          options[:only_find] = true
        end
        opts.on('--ext EXT', 'Adds additional file extensions. Default will only check for .rb and .patdoc files') do |o|
          #...
          fail "Need to complete this option! Currently, do not support C files."
        end
        opts.on('-o', '--output OUT', 'Moves the output from Origen.app.root/templates/web/patdoc to OUT') do |o|
          options[:output] = o
        end
        opts.on('-l', '--layout OUT', 'Moves the output of the generated layout from Origen.app.root/templates/web/layouts to OUT') do |o|
          options[:layout] = o
        end
        opts.on('-h', '--help', 'Shows this message') do
          puts opts
          exit
        end
      end.parse!
      
      OrigenDocHelpers::PatDoc.handler(ARGV, options)
    end
    
    # Prints the help command.
    # This includes:
    #   - Usage of the command
    #   - The currently registered tags
    #   - Links to useful stuff.
    def self.help
    end
  end
  end
end
