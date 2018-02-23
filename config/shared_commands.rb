aliases ={
#  "-x" => "execute",
}

@command = aliases[@command] || @command

case @command

when "test"
  test_pat = "/proj/k4l1_users1/b50956/testblocks/t_ip_scg_optionable/t_ip_scg/pattern/FIRC/48MHZ/scg_firc_48mhz_trim.rb"
  pattern = Pattern
  puts Pattern
  Pattern = OrigenDocHelpers::Pattern::Dummy.new
  puts Pattern
  require test_pat
  Pattern = pattern
  puts Pattern
  exit 0

when 'origen_doc_helpers:patdoc:generate', 'patdoc:generate'
  pattern = Pattern
  Pattern = OrigenDocHelpers::Pattern::Dummy.new
  
  Origen.load_application
  Origen.app.load_target!
  
  require "#{Origen.app!.root}/lib/origen_doc_helpers/patdoc/commands"
  OrigenDocHelpers::PatDoc::Commands.generate

  Pattern = pattern
  exit 0
  
when 'origen_doc_helpers:patdoc:help', 'patdoc:help'
  exit 0

else
  @plugin_commands << <<-EOT
origen_doc_helpers:patdoc:generate    Generates the PatDoc. Aliased as patdoc:generate
origen_doc_helpers:patdoc:help        Prints help command. Aliased as patdoc:help
  EOT

end
