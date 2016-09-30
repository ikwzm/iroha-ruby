require 'treetop'
require_relative '../iroha'

module Iroha
  module Builder
    module Exp
      require_relative './exp_parser'

      def load(file_name)
        parser = ExpParser.new
        result = nil
        File.open(file_name) do |file|
          result = parser.parse(file.read)
          if !result then
            fail parser.failure_reason
          end
        end
        return result.get
      end

      def parse(string)
        parser = ExpParser.new
        result = parser.parse(string)
        if !result then
          fail parser.failure_reason
        end
        return result.get
      end
  
      module_function :load
      module_function :parse
    end
  end
end

