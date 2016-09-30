module Iroha::Resource

  class CurrentState < Iroha::IResource
    attr_accessor :_connections
    CLASS_NAME   = "current-state"
    IS_EXCLUSIVE = true

    def initialize(id, input_types, output_types, params, option)
      super(CLASS_NAME, IS_EXCLUSIVE, id, input_types, output_types, params, option)
      @_connections = []
    end

    def _add_connection(module_id, table_id, resource_id)
      @_connections.push({:MODULE => module_id, :TABLE => table_id, :RESOURCE => resource_id})
      @_connections.uniq!
    end
  end

end
