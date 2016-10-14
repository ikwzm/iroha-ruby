module Iroha::Resource

  class CurrentState < Iroha::IResource
    attr_accessor :_connections
    CLASS_NAME   = "current-state"
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
