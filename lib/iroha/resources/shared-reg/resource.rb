module Iroha::Resource

  class SharedRegisterReader < Iroha::IResource
    attr_accessor :_connections
    CLASS_NAME   = "shared-reg-reader"
    OPTION_NAME  = "SHARED-REG".to_sym
    IS_EXCLUSIVE = true

    def initialize(id, input_types, output_types, params, option)
      if option.key?(OPTION_NAME) then
        option_params = option[OPTION_NAME]
        if option[OPTION_NAME].nil? then
          super(CLASS_NAME, IS_EXCLUSIVE, id, input_types, output_types, params, nil)
          @_connections = []
        elsif option_params.class == Hash and
              option_params.key?(:MODULE  ) and option_params[:MODULE  ].kind_of?(Integer) and
              option_params.key?(:TABLE   ) and option_params[:TABLE   ].kind_of?(Integer) and
              option_params.key?(:RESOURCE) and option_params[:RESOURCE].kind_of?(Integer) then
          super(CLASS_NAME, IS_EXCLUSIVE, id, input_types, output_types, params, nil)
          @_connections = []
          _add_connection(option_params[:MODULE], option_params[:TABLE], option_params[:RESOURCE])
        elsif option_params.size == 3 and
              option_params[0].kind_of?(Integer) and
              option_params[1].kind_of?(Integer) and
              option_params[2].kind_of?(Integer) then
          super(CLASS_NAME, IS_EXCLUSIVE, id, input_types, output_types, params, nil)
          @_connections = []
          _add_connection(option_params[0], option_params[1], option_params[2])
        else
          super(CLASS_NAME, IS_EXCLUSIVE, id, input_types, output_types, params, option)
        end
      else
          super(CLASS_NAME, IS_EXCLUSIVE, id, input_types, output_types, params, option)
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
        if resource.nil? then
          fail "Not found #{CLASS_NAME} resource(#{conn}) in #{_id_to_str}"
        end
        return "(#{OPTION_NAME} #{resource._owner_module._id} #{resource._owner_table._id} #{resource._id})"
      end
    end

    def _add_connection(module_id, table_id, resource_id)
      if @_connections.size == 0 then
        @_connections.push({:MODULE => module_id, :TABLE => table_id, :RESOURCE => resource_id})
      else
        fail "Can not connect two of the resources to #{CLASS_NAME} #{_id_to_str}"
      end
    end

    def _connect_to_shared_register
      if @_connections.size == 1 then
        connection = @_connections[0]
        register   = @_owner_design._find_resource(connection[:MODULE], connection[:TABLE], connection[:RESOURCE])
        if register.nil? then
          fail "Not found shared-reg resource(#{connection}) in #{_id_to_str}"
        end
        register._connect_to_shared_register_reader(self)
      end
    end
  end

  class SharedRegister < Iroha::IResource
    attr_accessor :_connections
    CLASS_NAME   = "shared-reg"
    IS_EXCLUSIVE = true

    def initialize(id, input_types, output_types, params, option)
      super(CLASS_NAME, IS_EXCLUSIVE, id, input_types, output_types, params, option)
      @_connections = []
    end

    def _connect_to_shared_register_reader(reader)
      if reader.kind_of?(SharedRegisterReader) then
        _add_connection(reader._owner_module._id, reader._owner_table._id, reader._id)
      else
        fail "Non shared-reg-reader(#{reader.class}) connect to #{CLASS_NAME}(#{id_to_str})"
      end
    end

    def _add_connection(module_id, table_id, resource_id)
      @_connections.push({:MODULE => module_id, :TABLE => table_id, :RESOURCE => resource_id})
      @_connections.uniq!
    end
  end

end
