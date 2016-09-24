class Iroha::IResource

  class Embedded < Iroha::IResource
    CLASS_NAME   = "embedded"
    IS_EXCLUSIVE = true
    def initialize(id, input_types, output_types, params, option)
      super(CLASS_NAME, IS_EXCLUSIVE, id, input_types, output_types, params, option)
    end
  end

end
