module Iroha::Builder::Simple::Resource

  class ChannelRead
    RESOURCE_PROC = Proc.new { |name, type| __add_resource(__method__, name, [type], [type], {}, {}) }
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
    RESOURCE_PROC = Proc.new { |name, type| __add_resource(__method__, name, [type], [type], {}, {}) }
    define_method('<=') do |regs|
      state = @_owner_table._on_state
      fail "Error: not on state"           if state.nil?
      fail "Error: source is not register" if regs.class != Iroha::Builder::Simple::IRegister
      state.__add_instruction(self, [], [], [regs], [])
      return self
    end
  end
    
end
