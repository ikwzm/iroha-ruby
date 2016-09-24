class Iroha::Builder::Simple::IResource

  class ForeignReg
    attr_accessor :_ref_regs
    RESOURCE_PROC = Proc.new do |name, regs|
      if    regs.class == IRegister then
        resource = __add_resource(__method__, name, [], [], {}, {:"FOREIGN-REG" => [regs._owner_module._id, regs._owner_table._id, regs._id]})
        resource._ref_regs = nil
        return resource
      elsif regs.class == Iroha::Builder::Simple::Reference then
        resource = __add_resource(__method__, name, [], [], {}, {:"FOREIGN-REG" => nil})
        resource._ref_regs = regs
        return resource
      elsif regs.nil?
        resource = __add_resource(__method__, name, [], [], {}, {:"FOREIGN-REG" => nil})
        resource._ref_regs = nil
        return resource
      else
        fail "Error: invalid register"
      end
    end
    def _resolve_reference
      if @_ref_regs.class == Reference then
        regs = @_ref_regs.resolve
        fail "Error: can not found register Reference(#{@_ref_regs.args})" if regs.class != Iroha::Builder::Simple::IRegister
        @_foreign_register_id = {:MODULE => regs._owner_module._id, :TABLE => regs._owner_table._id, :REGISTER => regs._id}
      end
    end
    define_method('<=') do |regs|
      state = @_owner_table._on_state
      fail "Error: not on state"           if state.nil?
      fail "Error: source is not register" if regs.class != Iroha::Builder::Simple::IRegister
      state.__add_instruction(self, [], [], [regs], [])
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

end
