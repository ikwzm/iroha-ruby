class Iroha::IResource

  class ExtInput  < Iroha::IResource
    CLASS_NAME   = "ext-input"
    IS_EXCLUSIVE = true
    def initialize(id, input_types, output_types, params, option)
      super(CLASS_NAME, IS_EXCLUSIVE, id, input_types, output_types, params, option)
    end
  end

  class ExtOutput < Iroha::IResource
    CLASS_NAME   = "ext-output"
    IS_EXCLUSIVE = true
    def initialize(id, input_types, output_types, params, option)
      super(CLASS_NAME, IS_EXCLUSIVE, id, input_types, output_types, params, option)
    end
  end

end
