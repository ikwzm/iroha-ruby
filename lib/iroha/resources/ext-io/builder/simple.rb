class Iroha::Builder::Simple::IResource

  class ExtInput
    RESOURCE_PROC = Proc.new{|name, width| __add_resource(__method__, name, [], [], {INPUT:  name, WIDTH: width}, {})}
    define_method('=>') do |regs|
      state = @_owner_table._on_state
      fail "Error: not on state"           if state.nil?
      fail "Error: source is not register" if regs.class != Iroha::Builder::Simple::IRegister
      state.__add_instruction(self, [], [], [], [regs])
      return self
    end
  end

  class ExtOutput
    RESOURCE_PROC = Proc.new{|name, width| __add_resource(__method__, name, [], [], {OUTPUT: name, WIDTH: width}, {})}
    define_method('<=') do |regs|
      state = @_owner_table._on_state
      fail "Error: not on state"           if state.nil?
      fail "Error: source is not register" if regs.class != Iroha::Builder::Simple::IRegister
      state.__add_instruction(self, [], [], [regs], [])
      return self
    end
  end

end
