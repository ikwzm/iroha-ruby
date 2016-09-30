module Iroha::Resource

  class CurrentState < Iroha::IResource
    attr_accessor :_connections
    CLASS_NAME   = "current-state"
    IS_EXCLUSIVE = true

    def initialize(id, input_types, output_types, params, option)
      super(CLASS_NAME, IS_EXCLUSIVE, id, input_types, output_types, params, option)
      @_connections = []
    end

    def _connect_to_port_input(port_input)
      if port_input.kind_of?(PortInput) then
        _add_connection(port_input._owner_module._id, port_input._owner_table._id, port_input._id)
      else
        fail "Non port-input(#{port_input.class}) connect to port-output(#{id_to_str})"
      end
    end

    def _add_connection(module_id, table_id, resource_id)
      @_connections.push({:MODULE => module_id, :TABLE => table_id, :RESOURCE => resource_id})
      @_connections.uniq!
    end
  end

end
