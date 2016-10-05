module Iroha::Builder::Simple::Resource

  class SubModuleTask

    TABLE_PROC = Proc.new {
      def SubModuleTask(name)
        __add_resource(:SubModuleTask, name, [], [], {}, {})
      end
    }

    def entry
      state = @_owner_table._on_state
      fail "Error: not on state" if state.nil?
      state.__add_instruction(self, [], [], [], [])
    end
  end

  class SubModuleTaskCall
    attr_accessor :_ref_task

    TABLE_PROC = Proc.new {
      def SubModuleTaskCall(name, task)
        if    task.class == SubModuleTask then
          resource = __add_resource(:SubModuleTaskCall, name, [], [], {}, {:'CALLEE-TABLE' => [task._owner_module._id, task._owner_table._id]})
          resource._ref_task = nil
          return resource
        elsif task.class == Iroha::Builder::Simple::Reference then
          resource = __add_resource(:SubModuleTaskCall, name, [], [], {}, {:'CALLEE-TABLE' => nil})
          resource._ref_task = task
          return resource
        elsif task.nil? then
          resource = __add_resource(:SubModuleTaskCall, name, [], [], {}, {:'CALLEE-TABLE' => nil})
          resource._ref_task = nil
          return resource
        else
          fail "Error: invalid task"
        end
      end
    }

    def _resolve_reference
      if @_ref_task.class == Iroha::Builder::Simple::Reference then
        task  = @_ref_task.resolve
        fail "Error: can not found task Reference(#{@_ref_task.args})" if task.nil?
        callee(task)
      end
    end

    def callee(task)
      if task.class == SubModuleTask then
        _set_callee_table(task._owner_table)
      else
        fail "Error: invalid task"
      end
    end

    def call
      state = @_owner_table._on_state
      fail "Error: not on state" if state.nil?
      state.__add_instruction(self, [], [], [], [])
    end
  end
end
