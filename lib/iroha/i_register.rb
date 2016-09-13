module Iroha

  class IRegister
    attr_reader   :id, :name, :klass, :type, :value
    attr_reader   :owner_design, :owner_module, :owner_table

    def initialize(id, name, klass, type, value)
      @id           = id                          ## TYPE: number
      set_name(name)                              ## TYPE: symbol or number or nil
      @klass        = klass                       ## TYPE: symbol
      @type         = type                        ## TYPE: Iroha::IValueType
      @value        = (value == "") ? nil : value ## TYPE: string or number
      @owner_design = nil
      @owner_module = nil
      @owner_table  = nil
    end

    def set_name(name)
      if name.class == String then
        if name == "" then
          @name = nil
        else
          @name = name.to_sym
        end
      else
          @name = name
      end
      return @name
    end

    def set_owner(owner_design, owner_module, owner_table)
      @owner_design = owner_design
      @owner_module = owner_module
      @owner_table  = owner_table
    end

    def set_owner_table(owner_table)
      @owner_table  = owner_table
    end

    def set_value(value)
      @value = value
    end

    def id_to_str
      if @owner_table != nil
        table_str = @owner_table.id_to_str
      else
        table_str = "UnknownTable"
      end
      return table_str + "::IRegister[{#@id}]"
    end

    def to_exp(indent)
      name  = (@name  == nil)? "()" : @name
      value = (@value == nil)? "()" : @value
      return indent + "(REGISTER #{@id} #{name} #{@klass} #{@type.to_exp} #{value})"
    end

    def self.convert_from(register)
      parent_class = Iroha.parent_class(self)
      type_class   = parent_class.const_get(:IValueType)
      id           = register.id
      name         = register.name
      klass        = register.klass
      type         = type_class.convert_from(register.type)
      value        = register.value
      self.new(id, name, klass, type, value)
    end    

  end

end
