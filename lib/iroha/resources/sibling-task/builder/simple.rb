class Iroha::Builder::Simple::IResource

  class SiblingTask
    RESOURCE_PROC = Proc.new { |name,type| __add_resource(__method__, name, [type], [], {}, {}) }
    def entry(regs)
      state = @_owner_table._on_state
      fail "Error: not on state"           if state.nil?
      fail "Error: source is not register" if regs.class != Iroha::Builder::Simple::IRegister
      state.__add_instruction(self, [], [], [], [regs])
      return self
    end
  end
    
  class SiblingTaskCall
    attr_accessor :_ref_task
    RESOURCE_PROC = Proc.new do  |name, type, task|
      if    task.class == SiblingTask then
        resource = __add_resource(__method__, name, [type], [], {}, {:'CALLEE-TABLE' => [task._owner_module._id, task._owner_table._id]})
        resource._ref_task = nil
        return resource
      elsif task.class == Iroha::Builder::Simple::Reference then
        resource = __add_resource(__method__, name, [type], [], {}, {:'CALLEE-TABLE' => nil})
        resource._ref_task = task
        return resource
      elsif task.nil? then
        resource = __add_resource(__method__, name, [type], [], {}, {:'CALLEE-TABLE' => nil})
        resource._ref_task = nil
        return resource
      else
        fail "Error: invalid task"
      end
    end
    def _resolve_reference
      if @_ref_task.class == Iroha::Builder::Simple::Reference then
        task  = @ref_task.resolve
        fail "Error: can not found task Reference(#{@ref_task.args})" if task.nil?
        callee(task)
      end
    end
    def callee(task)
      if task.class == SiblingTask then
        @_callee_table_id = {:MODULE => task._owner_module._id, :TABLE => task._owner_table._id}
      else
        fail "Error: invalid task"
      end
    end
    def call(regs)
      state = @_owner_table._on_state
      fail "Error: not on state"           if state.nil?
      fail "Error: source is not register" if regs.class != Iroha::Builder::Simple::IRegister
      state.__add_instruction(self, [], [], [regs], [])
    end
    def wait
      state = @_owner_table._on_state
      fail "Error: not on state"           if state.nil?
      state.__add_instruction(self, [:wait], [], [], [])
    end
  end
    
end