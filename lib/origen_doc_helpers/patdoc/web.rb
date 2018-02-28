module OrigenDocHelpers

  # Methods to be used in the context of the 'origen web compile'
  # These are assuming that the patdoc has already been run (or it will call it itself)
  module PatDoc
    module Web
      # Attempts to grab the sitemap generated from patdoc.
      #def self.sitemap(options={})
      #end
      
      # Generates the navbar text for patterns and its modules.
      # This requires that the sitemap is already generated.
      # The default sitemap will be at: Origen.app.root/templates/web/origen_doc_helpers/patdoc/
      def self.navbar(options={}) 
        def self.print_group(name, group, options)
          html = []
          
          html << '<li class="dropdown-submenu">'
          html << "<a class=\"test\" tabindex=\"-1\" href=\"#{options[:server_root].join(group['listing_file'])}\"><span class=\"glyphicon glyphicon-menu-right\" style=\"float:right;\"></span> <span style=\"display: inline-block;margin-right: 20px;\">#{name}</span> </a>"
          html << '<ul class="dropdown-menu">'
          
          if group.key?("groups") && !group["groups"].empty?
            html << '<li class="dropdown-header">Groups</li>'
            
            group["groups"].each do |n, g|
              html += print_group(n, g, options)
            end
          end
          
          if group.key?("patterns") && !group["patterns"].empty?
            html << "<li class=\"divider\"></li>"
            html << '<li class="dropdown-header">Patterns</li>'
            
            group["patterns"].each do |n, file|
              html << "<li><a href=\"#{options[:server_root].join(file)}\">#{n}</a></li>"
            end
          end
          
          html << '</ul>'
          html << '</li>'

          html
        end

        # Make sure we can find the sitemap file.
        sitemap = OrigenDocHelpers::PatDoc.read_sitemap(options)
        menu_name = options[:menu_name] || 'Patterns'
        full_listing_text = options[:full_listing_text] || 'Full Pattern Listing'
        options[:root] = sitemap["root"] unless options.key?(:root)
        options[:server_root] = Pathname.new(Origen.generator.compiler.path(options[:root]))
        
        html = []
        html << "<li id=\"#{Origen.app.name}_pattern_nav\" class=\"dropdown\">"
        html << "<a class=\"dropdown-toggle\" data-toggle=\"dropdown\" href=\"#{options[:server_root]}/\">#{menu_name} <span class=\"caret\"></span></a>"
        #html << <span class="caret"></span></a>
        
        # Add the submodules
        html << '<ul class="dropdown-menu">'
        html << "<li><a href=\"#{options[:server_root].join(sitemap['listing_file'])}\">#{full_listing_text}</a></li>"
        
        if sitemap["groups"] && !sitemap["groups"].empty?
          html << "<li class=\"divider\"></li>"
          html << '<li class="dropdown-header">Groups</li>'
          
          sitemap["groups"].each do |name, group|
            html += print_group(name, group, options)
          end
        end
        
        if sitemap["patterns"] && !sitemap["patterns"].empty?
          html << "<li class=\"divider\"></li>"
          html << '<li class="dropdown-header">Patterns</li>'
          
          sitemap["patterns"].each do |name, file|
            html << "<li><a href=\"#{Origen.generator.compiler.path Pathname.new(options[:root]).join(file).to_s}\">#{name}</a></li>"
          end
        end
        
        #sitemap.each do |k, v|
        #  #if v.is_a?(Array)
        #  #  html << "<li><a href=\"#\">#{k}</a></li>"
        #  #end
        #  
        #  if v.is_a?(Hash)
        #    html += print_submodule(k, v, options)
        #  else
        #    html << "<li><a href=\"#\">#{k}</a></li>"
        #  end
        #end
        
        html << '</ul>'
        
        html << '</li>'
        
        html << <<-EOT
<script>
$(document).ready(function(){
  $('head').append('<style>.dropdown-submenu{position:relative;}</style>')
  $('head').append('<style>.dropdown-submenu>.dropdown-menu{top:-75%;left:100%}</style>')
  $('head').append('<style>.dropdown-submenu:hover>.dropdown-menu{display:block;}</style>')
  $('head').append('<style>.dropdown-submenu>a{display:inline-block}</style>')
});
</script>
  EOT
=begin
  $('head').append('<style>.dropdown-submenu>.dropdown-menu{top:0;left:-95%;max-width:180px;margin-top:-6px;margin-right:-1px;-webkit-border-radius:6px 6px 6px 6px;-moz-border-radius:6px 6px 6px 6px;border-radius:6px 6px 6px 6px;}</style>')
  
  $('head').append('<style>.dropdown-submenu>a:after{display:block;content:" ";float:left;width:0;height:0;border-color:transparent;border-style:solid;border-width:5px 5px 5px 0;border-right-color:#999;margin-top:5px;margin-right:10px;}</style>')
  $('head').append('<style>.dropdown-submenu:hover>a:after{border-left-color:#ffffff;}</style>')
  $('head').append('<style>.dropdown-submenu.pull-left{float:none;}.dropdown-submenu.pull-left>.dropdown-menu{left:-100%;margin-left:10px;-webkit-border-radius:6px 6px 6px 6px;-moz-border-radius:6px 6px 6px 6px;border-radius:6px 6px 6px 6px;}</style>')
  $('head').append('<style>.dropdown-menu-right {margin-left:0;}</style>')
=end

#<script>
#$(document).ready(function(){
#  $('head').append('<style>.dropdown-submenu{position:relative;}</style>')
#  $('head').append('<style>.dropdown-submenu>.dropdown-menu{top:0;left:-95%;max-width:180px;margin-top:-6px;margin-right:-1px;-webkit-border-radius:6px 6px 6px 6px;-moz-border-radius:6px 6px 6px 6px;border-radius:6px 6px 6px 6px;}</style>')
#  $('head').append('<style>.dropdown-submenu:hover>.dropdown-menu{display:block;}</style>')
#  $('head').append('<style>.dropdown-submenu>a:after{display:block;content:" ";float:left;width:0;height:0;border-color:transparent;border-style:solid;border-width:5px 5px 5px 0;border-right-color:#999;margin-top:5px;margin-right:10px;}</style>')
#  $('head').append('<style>.dropdown-submenu:hover>a:after{border-left-color:#ffffff;}</style>')
#  $('head').append('<style>.dropdown-submenu.pull-left{float:none;}.dropdown-submenu.pull-left>.dropdown-menu{left:-100%;margin-left:10px;-webkit-border-radius:6px 6px 6px 6px;-moz-border-radius:6px 6px 6px 6px;border-radius:6px 6px 6px 6px;}</style>')
#  $('head').append('<style>.dropdown-menu-right {margin-left:0;}</style>')
#});
#</script>
#  EOT
#<script>
#$(document).ready(function(){
#  $('.dropdown-submenu').css(""
#  //$('.dropdown-submenu a.test').on("click", function(e){
#    //$(this).next('ul').toggle();
#    //e.stopPropagation();
#    //e.preventDefault();
#  //});
#});
#</script>
#  EOT

        html.join("\n")
      end
    end
  end
end
