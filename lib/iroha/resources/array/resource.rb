class Iroha::IResource

  class Array < Iroha::IResource
    CLASS_NAME   = "array"
    IS_EXCLUSIVE = true
    def initialize(id, input_types, output_types, params, option)
      if option.key?(:ARRAY) and
         (option[:ARRAY][0].kind_of?(Integer          )) and
         (option[:ARRAY][1].kind_of?(Iroha::IValueType)) and
         (option[:ARRAY][2] == :EXTERNAL or option[:ARRAY][2] == :INTERNAL) and
         (option[:ARRAY][3] == :RAM      or option[:ARRAY][3] == :ROM     ) then
        super(CLASS_NAME, IS_EXCLUSIVE, id, input_types, output_types, params, nil)
        @_addr_width  = option[:ARRAY][0]
        @_value_type  = option[:ARRAY][1]
        @_is_external = (option[:ARRAY][2] == :EXTERNAL)
        @_is_ram      = (option[:ARRAY][3] == :RAM     )
      else
        super(CLASS_NAME, IS_EXCLUSIVE, id, input_types, output_types, params, option)
      end
    end
    def _option_clone
      return {:ARRAY => {:ADDR_WIDTH => @_addr_width, :VALUE_TYPE => @_value_type, :EXTERNAL => @_is_external, :RAM => @_is_ram}}
    end
    def _option_to_exp
      external = (@_is_external == true) ? "EXTERNAL" : "INTERNAL"
      ram      = (@_is_ram      == true) ? "RAM"      : "ROM"
      return "(ARRAY #{@_addr_width} #{@_value_type._to_exp} #{external} #{ram})"
    end
  end

end
