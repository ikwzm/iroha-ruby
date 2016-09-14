module Iroha

  class IRegister
    attr_reader   :_id, :_name, :_class, :_type, :_value
    attr_reader   :_owner_design, :_owner_module, :_owner_table

    def initialize(id, name, klass, type, value)
      @_id           = id                          ## TYPE: number
      _set_name(name)                              ## TYPE: symbol or number or nil
      @_class        = klass                       ## TYPE: symbol
      @_type         = type                        ## TYPE: Iroha::IValueType
      @_value        = (value == "") ? nil : value ## TYPE: string or number
      @_owner_design = nil
      @_owner_module = nil
      @_owner_table  = nil
    end

    def _set_name(name)
      if name.class == String then
        if name == "" then
          @_name = nil
        else
          @_name = name.to_sym
        end
      else
          @_name = name
      end
      return @_name
    end

    def _set_owner(owner_design, owner_module, owner_table)
      @_owner_design = owner_design
      @_owner_module = owner_module
      @_owner_table  = owner_table
    end

    def _set_owner_table(owner_table)
      @_owner_table  = owner_table
    end

    def _set_value(value)
      @_value = value
    end

    def _id_to_str
      if @_owner_table != nil
        table_str = @_owner_table._id_to_str
      else
        table_str = "UnknownTable"
      end
      return table_str + "::IRegister[{#@_id}]"
    end

    def _to_exp(indent)
      name  = (@_name  == nil)? "()" : @_name
      value = (@_value == nil)? "()" : @_value
      return indent + "(REGISTER #{@_id} #{name} #{@_class} #{@_type._to_exp} #{value})"
    end

    def self.convert_from(register)
      parent_class = Iroha.parent_class(self)
      type_class   = parent_class.const_get(:IValueType)
      id           = register._id
      name         = register._name
      klass        = register._class
      type         = type_class.convert_from(register._type)
      value        = register._value
      self.new(id, name, klass, type, value)
    end    

  end

end
