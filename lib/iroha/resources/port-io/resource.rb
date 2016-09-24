class Iroha::IResource

  class PortInput  < Iroha::IResource
    attr_accessor :_connections
    CLASS_NAME   = "port-input"
    OPTION_NAME  = "PORT-INPUT".to_sym
    IS_EXCLUSIVE = true
    def initialize(id, input_types, output_types, params, option)
      if option.key?(OPTION_NAME) then
        if option[OPTION_NAME].nil? then
          super(CLASS_NAME, IS_EXCLUSIVE, id, input_types, output_types, params, nil)
          @_connections = []
        elsif option[OPTION_NAME].size == 3 and
              option[OPTION_NAME][0].kind_of?(Integer) and
              option[OPTION_NAME][1].kind_of?(Integer) and
              option[OPTION_NAME][2].kind_of?(Integer) then
          super(CLASS_NAME, IS_EXCLUSIVE, id, input_types, output_types, params, nil)
          @_connections = []
          _add_connection(option[OPTION_NAME][0], option[OPTION_NAME][1], option[OPTION_NAME][2])
        else
          super(CLASS_NAME, IS_EXCLUSIVE, id, input_types, output_types, params, option)
        end
      else
          super(CLASS_NAME, IS_EXCLUSIVE, id, input_types, output_types, params, option)
      end
    end
    def _add_connection(module_id, table_id, resource_id)
      if @_connections.size == 0 then
        @_connections.push({:MODULE => module_id, :TABLE => table_id, :RESOURCE => resource_id})
      else
        fail "Can not connect two of the resources to #{CLASS_NAME} #{_id_to_str}"
      end
    end
    def _option_clone
      if @_connections.size == 0 then
        return {OPTION_NAME => nil}
      else
        return {OPTION_NAME => @_connections[0]}
      end
    end
    def _option_to_exp
      if @_connections.size == 0 then
        return "(#{OPTION_NAME})"
      else
        conn     = @_connections[0]
        resource = @_owner_design._find_resource(conn[:MODULE], conn[:TABLE], conn[:RESOURCE])
        if resource == nil then
          fail "Not found #{CLASS_NAME} resource(#{conn}) in #{_id_to_str}"
        end
        return "(#{OPTION_NAME} #{resource._owner_module._id} #{resource._owner_table._id} #{resource._id})"
      end
    end
  end

  class PortOutput < Iroha::IResource
    attr_accessor :_connections
    CLASS_NAME   = "port-output"
    IS_EXCLUSIVE = true
    def initialize(id, input_types, output_types, params, option)
      super(CLASS_NAME, IS_EXCLUSIVE, id, input_types, output_types, params, option)
      @_connections = []
    end
    def _add_connection(module_id, table_id, resource_id)
      @_connections.push({:MODULE => module_id, :TABLE => table_id, :RESOURCE => resource_id})
    end
  end

end
