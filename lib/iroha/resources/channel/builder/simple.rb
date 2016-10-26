module Iroha::Builder::Simple::Resource

  class ChannelRead

    TABLE_PROC = Proc.new {
      def ChannelRead(**args)
        fail "Error: #{__method__} illegal argument size" if args.size != 1
        name, type = args.shift
        __add_resource(:ChannelRead, name, [type], [type], {}, {})
      end
    }

    define_method('<=') do |channel_read|
      @_owner_design.__add_channel(self, channel_read)
      return self
    end

    define_method('=>') do |regs|
      state = @_owner_table._on_state
      fail "Error: not on state"           if state.nil?
      fail "Error: source is not register" if regs.class != Iroha::Builder::Simple::IRegister
      state.__add_instruction(self, [], [], [], [regs])
      return self
    end
  end

  class ChannelWrite

    TABLE_PROC = Proc.new {
      def ChannelWrite(**args)
        fail "Error: #{__method__} illegal argument size" if args.size != 1
        name, type = args.shift
        __add_resource(:ChannelWrite, name, [type], [type], {}, {})
      end
    }

    define_method('<=') do |regs|
      state = @_owner_table._on_state
      fail "Error: not on state"           if state.nil?
      fail "Error: source is not register" if regs.class != Iroha::Builder::Simple::IRegister
      state.__add_instruction(self, [], [], [regs], [])
      return self
    end
  end
    
end
