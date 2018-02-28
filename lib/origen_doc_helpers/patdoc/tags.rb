module OrigenDocHelpers
  module PatDoc
    module Tags
      
      # Base class for tags.
      class Base
        attr_reader :name
        attr_reader :value
        attr_reader :options
        
        METHODS = []
        
        def initialize
          #@name = name.demodulize
          @value = nil
          @options = nil
          @tag_set = false
          @name = self.class.name.demodulize
          
          # Define the methods on the tag.
          #(METHODS + [name]).each do |m|
          #  puts m.to_s.cyan
          #  define_singleton_method(m) do |value, options={}, &block|
          #    setup(value, options, block)
          #  end
          #end
        end
        
        def generate(options={})
        end
        
        # The default to_html is pretty boring. Just print the name and the value.
        def to_html(options={})
          "<strong>#{name}</strong>: #{array_to_html(value)}"
        end
        
        #def value
        #  @value
        #end
        
        def setup(*args, &block) #value, options={}, &block)
          @value = args[0]
          @tag_set = true
          @value
        end
        
        def array_to_html(arr, options={})
          if arr.is_a?(Array)
            arr.join('<br>')
          else
            arr
          end
        end
        
        def tag_set?
          @tag_set
        end
      end
    
      # A single tag can only have a single value set. Trying to set this more than once raises an exception.
      class SingleTag < Base
        
        def initialize
          super
          #@name = name
          #@setup = options[:setup]
          #@generate = options[:generate]
          #@docs = options[:usage]
        end
        
        def generate
        end
        
        # For a single tag, merging the other tag simply does nothing.
        
        #def setup(value, options={}, &block)
        #  @value = value
        #  @options = options
        #end
      end
      
      # A tag that can be called multiple times. This will append the values.
      class MultiTag < Base
        def initialize
          super
          
          # MultiTags will shift in new values and options each time it is called.
          @value = []
          @options = []
        end
        
        def generate
        end
        
        def setup(value, options={}, &block)
          @tag_set = true
          @value << value[0]
          @options << options[1]
        end
        
        # Merging a multi-tag does not override it. Instead, it prepends whatever the
        # value of other_tag is to the current value.
        def merge!(other_tag)
          self.value.prepend(other_tag.value)
        end
      end
      
      def self.add_tag(tag_class)
        name = tag_class.name.demodulize.underscore
        self.tags[name] = tag_class #.new
        
        methods = tag_class.const_defined?(:METHODS) ? tag_class.const_get(:METHODS) : []
        methods += [name]
        
        puts name.cyan
        methods.each do |m|
          define_method(m) do |*args, &block|
            tags[name].setup(args, &block)
          end
        end
      end
      
      def self.tags
        @tags ||= Hash.new
      end
      
      def self.has_tag?
      end
      
      def self.[](tag)
        self.tags[tag]
      end
      singleton_class.send(:alias_method, :tag, :[])
      
      # Add the default tags.
      # The user can add additional ones/override these after instantiation
      class Purpose < SingleTag
      end
      
      class Department < MultiTag
        METHODS = [:departments]
      end
      
      class Author < MultiTag
      end
      
      class Email < MultiTag
      end
      
      class TestStep < MultiTag
        def to_html(optios={})
          html = []
          html << '<div class="panel panel-default">'
          html << '<div class="panel-heading">This pattern contains the following Steps:</div>'
          html << '<div class="panel-body">'
          html << '<ul class="list-group">'
          
          @value.each do |step|
            html << '<li class="list-group-item">'
            html << step
            html << '</li>'
          end
          
          html << '</ul>'
          html << '</div>'
          html << '</div>'
          html.join("\n")
        end
      end
      
      class DigitalCapture < MultiTag
        METHODS = [:digcap, :dig_cap]
      end
      
      class Requirement < MultiTag
        METHODS = [:req, :reqs, :requirements]
      end
      
      class Assumption < MultiTag
      end
      
      self.add_tag(Department)
      self.add_tag(Author)
      self.add_tag(Email)
      self.add_tag(Purpose)
      self.add_tag(TestStep)
      self.add_tag(DigitalCapture)
      self.add_tag(Requirement)
      self.add_tag(Assumption)
      
      # These method will be available when including the module.
      def has_tag?(tag)
      end
      
      def [](tag)
      end
      
      # Prints out all the available tags, the description of each (if provided, warnings otherwise), and its 
      # current value.
      def details
        puts "Showing Details for OrigenDocHelpers::PatDoc..."
        
        puts "Currently Registered Tags: "
        #puts @tags
        tags.each do |name, tag|
          puts "  #{name}:"
          
          if tag.respond_to?(:description)
            puts "    Description:"
            tag.description.each { |line| puts "      #{line}" }
          else
            puts "    No description avaliable!".red
          end
          #puts tag.value
          
          if !tag.value.nil? #&& (tag.value.respond_to?(:empty) && !tag.value.empty?)
            puts "    Current Value (#{tag.value.class}):"
            puts "      #{tag.value}"
          end
        end
        
        # Print the tags that have a value again in a separate verbage.
        #puts "Current State of Tags (if set): "
        #tags.each do |t|
        #end
      end
      alias_method :show_details, :details
      alias_method :show, :details
      alias_method :help, :details
      
      #def method_missing(m, *args, &block)
      #  if OrigenDocHelpers::PatDoc::Tags.tags.include?(m)
      #    puts OrigenDocHelpers::PatDoc::Tags[m].setup(args, &block)
      #  end
      #  fail "No tag: #{m}"
      #end
      
      #def tags
      #  #OrigenDocHelpers::PatDoc::Tags.tags
      #  @tags
      #end
      
    end
  end
end
