module Iroha::Type

  class State < Iroha::IType
    CLASS_NAME = "STATE"

    attr_reader :_module_id, :_table_id
    attr_reader :_width

    def initialize(*options)
      if options.size == 2 and
         options[0].kind_of?(Integer) and
         options[1].kind_of?(Integer) then
        @_module_id = options[0]
        @_table_id  = options[1]
        @_width     = nil
      else
        exp_str = [CLASS_NAME].concat(options).join(" ")
        fail "(#{exp_str}) is invalid option."
      end
    end

    def _to_exp
      return "(#{CLASS_NAME} #{@_module_id} #{@_table_id})"
    end

    def self.convert_from(type)
      self.new(type._module_id, type._table_id)
    end
  end

end
