require 'origen'
require_relative '../config/application.rb'

module OrigenDocHelpers
  autoload :PDF, 'origen_doc_helpers/pdf'
  autoload :HtmlFlowFormatter, 'origen_doc_helpers/html_flow_formatter'
  autoload :ListFlowFormatter, 'origen_doc_helpers/list_flow_formatter'
  autoload :FlowPageGenerator, 'origen_doc_helpers/flow_page_generator'
  autoload :ModelPageGenerator, 'origen_doc_helpers/model_page_generator'
  
  module Pattern
    class Dummy
      def create(options={})
        nil
      end
    end
  end
end

require 'origen_doc_helpers/helpers'

Dir.glob("#{File.dirname(__FILE__)}/origen_doc_helpers/**/*.rb").sort.each do |file|
  require file
end

module OrigenDocHelpers
  def self.generate_flow_docs(options = {}, &block)
    FlowPageGenerator.run(options, &block)
  end

  def self.generate_model_docs(options = {}, &block)
    ModelPageGenerator.run(options, &block)
  end
end
