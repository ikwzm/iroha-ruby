module Iroha::Resource

  class Assert < Iroha::IResource
    CLASS_NAME   = "assert"
    IS_EXCLUSIVE = false
    def initialize(id, input_types, output_types, params, option)
      super(CLASS_NAME, IS_EXCLUSIVE, id, input_types, output_types, params, option)
    end
  end

end
