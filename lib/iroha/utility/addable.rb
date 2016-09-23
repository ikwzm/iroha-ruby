module Iroha
  module Utility
  end
end

module Iroha::Utility::Addable

  module IDesign

    def _add_new_initialize
      _add_new_module_id_initialize
      _add_new_channel_id_initialize
    end

    def _add_new_module_id_initialize
      @_add_new_module_id  = 1
      self._modules.values.each do |mod|
        if mod._id >= @_add_new_module_id then
          @_add_new_module_id = mod._id + 1
        end
      end
    end
      
    def _add_new_channel_id_initialize
      @_add_new_channel_id  = 1
      self._channels.values.each do |channel|
        if channel._id >= @_add_new_channel_id then
          @_add_new_channel_id = channel._id + 1
        end
      end
    end

    def _add_new_module(module_class, name, parent_id, params, table_list)
      mod = module_class.new(@_add_new_module_id, name, parent_id, params, table_list)
      @_add_new_module_id = @_add_new_module_id + 1
      return self._add_module(mod)
    end

    def _add_new_channel(channel_class, type, r_module_id, r_table_id, r_resource_id, w_module_id, w_table_id, w_resource_id)
      channel = channel_class.new(@_add_new_channel_id, type, r_module_id, r_table_id, r_resource_id, w_module_id, w_table_id, w_resource_id)
      @_add_new_channel_id = @_add_new_channel_id + 1
      return self._add_channel(channel)
    end
      
  end

  module IModule

    def _add_new_initialize
      _add_new_table_id_initialize
    end

    def _add_new_table_id_initialize
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

    attr_writer :_init_state_id

    def _add_new_initialize
      _add_new_register_id_initialize
      _add_new_resource_id_initialize
      _add_new_state_id_initialize
      _add_new_instruction_id_initialize
    end

    def _add_new_register_id_initialize
      @_add_new_register_id = 1
      self._registers.values.each do |register|
        if register._id >= @_add_new_register_id then
          @_add_new_register_id = register._id + 1
        end
      end
    end

    def _add_new_resource_id_initialize
      @_add_new_resource_id = 1
      self._resources.values.each do |resource|
        if resource._id >= @_add_new_resource_id then
          @_add_new_resource_id = resource._id + 1
        end
      end
    end

    def _add_new_state_id_initialize
      @_add_new_state_id = 1
      self._states.values.each do |state|
        if state._id >= @_add_new_state_id then
          @_add_new_state_id = state._id + 1
        end
      end
    end

    def _add_new_instruction_id_initialize
      @_add_new_instruction_id = 1
      self._states.values.each do |state|
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
