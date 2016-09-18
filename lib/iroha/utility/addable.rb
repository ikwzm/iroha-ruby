module Iroha
  module Utility
  end
end

module Iroha::Utility
  module Addable
    module IModule
      def _add_new_initialize
        @_add_new_table_id = 1
        self._tables.values.each do |table|
          if table._id >= @_add_new_table_id then
            @_add_new_table_id = table._id + 1
          end
        end
      end
      def _add_new_table(table_class, name, resource_list, register_list, state_list, init_state_id)
        table = table_class.new(@_add_new_table_id, name, resource_list, register_list, state_list, init_state_id)
        @_add_new_table_id = @_add_new_table_id + 1
        return self._add_table(table)
      end
    end
    
    module ITable
      def _add_new_initialize
        @_add_new_register_id    = 1
        @_add_new_resource_id    = 1
        @_add_new_state_id       = 1
        @_add_new_instruction_id = 1
        self._registers.values.each do |register|
          if register._id >= @_add_new_register_id then
            @_add_new_register_id = register._id + 1
          end
        end
        self._resources.values.each do |resource|
          if resource._id >= @_add_new_resource_id then
            @_add_new_resource_id = resource._id + 1
          end
        end
        self._states.values.each do |state|
          if state._id >= @_add_new_state_id then
            @_add_new_state_id = state._id + 1
          end
          state._instructions.values.each do |insn|
            if insn._id >= @_add_new_instruction_id then
              @_add_new_instruction_id = insn._id + 1
            end
          end
        end
      end

      def _add_new_register(register_class, name, klass, type, value)
        register = register_class.new(@_add_new_register_id, name, klass, type, value)
        @_add_new_register_id = @_add_new_register_id + 1
        return self._add_register(register)
      end

      def _add_new_resource(resource_class, input_types, output_types, params, option)
        resource = resource_class.new(@_add_new_resource_id, input_types, output_types, params, option)
        @_add_new_resource_id = @_add_new_resource_id + 1
        return self._add_resource(resource)
      end

      def _add_new_state(state_class, name, instruction_list)
        state    = state_class.new(@_add_new_state_id, name, instruction_list)
        @_add_new_state_id = @_add_new_state_id + 1
        return self._add_state(state)
      end

      def _add_new_instruction(instruction_class, res_class, res_id, op_resources, next_states, input_registers, output_registers)
        instruction = instruction_class.new(
          @_add_new_instruction_id,
          res_class               ,
          res_id                  ,
          op_resources            ,
          next_states             ,
          input_registers         ,
          output_registers
        )
        @_add_new_instruction_id = @_add_new_instruction_id + 1
        return instruction
      end

    end

    module IState

      def _add_new_instruction(instruction_class, res_class, res_id, op_resources, next_states, input_registers, output_registers)
        instruction = self._owner_table._add_new_instruction(
          instruction_class    ,
          res_class            ,
          res_id               ,
          op_resources         ,
          next_states          ,
          input_registers      ,
          output_registers
        )
        return self._add_instruction(instruction)
      end
    end

  end
end
