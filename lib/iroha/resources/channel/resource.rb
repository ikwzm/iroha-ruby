class Iroha::IResource

  class ChannelRead  < Iroha::IResource
    CLASS_NAME   = "channel-read"
    IS_EXCLUSIVE = true
    def initialize(id, input_types, output_types, params, option)
      super(CLASS_NAME, IS_EXCLUSIVE, id, input_types, output_types, params, option)
    end
  end

  class ChannelWrite < Iroha::IResource
    CLASS_NAME   = "channel-write"
    IS_EXCLUSIVE = true
    def initialize(id, input_types, output_types, params, option)
      super(CLASS_NAME, IS_EXCLUSIVE, id, input_types, output_types, params, option)
    end
  end

end
