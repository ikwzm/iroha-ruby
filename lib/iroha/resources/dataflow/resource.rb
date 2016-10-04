module Iroha::Resource

  class DataFlowIn  < Iroha::IResource
    CLASS_NAME   = "dataflow-in"
    IS_EXCLUSIVE = true
    def initialize(id, input_types, output_types, params, option)
      super(CLASS_NAME, IS_EXCLUSIVE, id, input_types, output_types, params, option)
    end
  end

end
