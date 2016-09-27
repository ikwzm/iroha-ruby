module Iroha

  class IResource
    attr_reader :_class_name, :_is_exclusive
    attr_reader :_id, :_input_types, :_output_types, :_params, :_option
    attr_reader :_owner_design, :_owner_module, :_owner_table
    
    def initialize(class_name, is_exclusive, id, input_types, output_types, params, option)
      @_class_name   = class_name      ## TYPE: string
      @_is_exclusive = is_exclusive    ## TYPE: boolean
      @_id           = id              ## TYPE: id
      @_input_types  = input_types     ## TYPE: Array[Iroha::IValueType]
      @_output_types = output_types    ## TYPE: Array[Iroha::IValueType]
      @_params       = params          ## TYPE: Iroha::IParams
      @_option       = Hash.new;       ## Type: Hash {name:string, value:string or number}
      @_owner_design = nil
      @_owner_module = nil
      @_owner_table  = nil
      return if option == nil
      return if option.class == Hash and option.size == 0
      fail "(RESOURCE #{class_name} #{id} ... #{option}) is invalid option."
    end

    def _set_owner(owner_design, owner_module, owner_table)
      @_owner_design = owner_design
      @_owner_module = owner_module
      @_owner_table  = owner_table
    end

    def _set_owner_table(owner_table)
      @_owner_table  = owner_table
    end

    def _to_exp(indent)
      if self.class.method_defined?(:_option_to_exp) then
        option_exp = _option_to_exp()
      else
        option_exp = ""
      end
      return indent + "(RESOURCE #{@_id} #{@_class_name} " +
             "(" + @_input_types .map{|t|t._to_exp}.join(" ") + ") " +
             "(" + @_output_types.map{|t|t._to_exp}.join(" ") + ") " +
             @_params._to_exp("") + option_exp + ")"
    end

    def _option_clone
      return Hash.new
    end

    def self.convert_from(resource)
      class_name   = resource.class.to_s.split(/::/).last
      parent_class = Iroha.parent_class(self)
      params_class = parent_class.const_get(:IParams)
      type_class   = parent_class.const_get(:IValueType)
      id           = resource._id
      input_types  = resource._input_types.map{ |value_type| type_class.convert_from(value_type)}
      output_types = resource._output_types.map{|value_type| type_class.convert_from(value_type)}
      params       = params_class.convert_from(resource._params)
      option       = resource._option_clone
      parent_class.const_get(:Resource).const_get(class_name).new(id, input_types, output_types, params, option)
    end

    def _id_to_str
      if @_owner_table != nil
        table_str = @_owner_table._id_to_str
      else
        table_str = "UnknownTable"
      end
      return table_str + "::IResource(#{@_class_name})[#{@_id}]"
    end

  end

end
