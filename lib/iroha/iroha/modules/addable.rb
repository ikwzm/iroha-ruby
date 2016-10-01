

module Iroha
  module Modules
  end
end

module Iroha::Modules::Addable

  class  IdentfierGenerator

    def  initialize(init_id, inc, values)
      @init_id = init_id
      @inc     = (inc == 0 or inc == nil) ? 1 : inc
      @new_id  = @init_id
      reset(values)
    end

    def  update
      new_id  = @new_id
      @new_id = @new_id + @inc
      return new_id
    end

    def  reset(values)
      @new_id = @init_id
      if @inc > 0 then
        values.each do |value|
          if value._id >= @new_id then
            @new_id = value._id + @inc
          end
        end
      else
        values.each do |value|
          if value._id <= @new_id then
            @new_id = value._id + @inc
          end
        end
      end
    end
    
  end

  module IDesign

    attr_reader :_module_id_generator
    attr_reader :_channel_id_generator

    def _add_new_initialize
      @_module_id_generator  = IdentfierGenerator.new(1,1, self._modules .values)
      @_channel_id_generator = IdentfierGenerator.new(1,1, self._channels.values)
    end

    def _add_new_module(module_class, name, parent_id, params, table_list)
      new_id = @_module_id_generator.update
      mod    = module_class.new(new_id, name, parent_id, params, table_list)
      return self._add_module(mod)
    end

    def _add_new_channel(channel_class, type, r_module_id, r_table_id, r_resource_id, w_module_id, w_table_id, w_resource_id)
      new_id  = @_channel_id_generator.update
      channel = channel_class.new(new_id, type, r_module_id, r_table_id, r_resource_id, w_module_id, w_table_id, w_resource_id)
      return self._add_channel(channel)
    end
      
  end

  module IModule

    attr_reader :_table_id_generator
    
    def _add_new_initialize
      @_table_id_generator = IdentfierGenerator.new(1,1, self._tables.values)
    end

    def _add_new_table(table_class, name, resource_list, register_list, state_list, init_state_id)
      new_id = @_table_id_generator.update
      table  = table_class.new(new_id, name, resource_list, register_list, state_list, init_state_id)
      return self._add_table(table)
    end

  end
    
  module ITable

    attr_reader :_register_id_generator
    attr_reader :_resource_id_generator
    attr_reader :_state_id_generator
    attr_reader :_instruction_id_generator
    attr_writer :_init_state_id

    def _add_new_initialize
      @_register_id_generator    = IdentfierGenerator.new(1,1, self._registers.values)
      @_resource_id_generator    = IdentfierGenerator.new(1,1, self._resources.values)
      @_state_id_generator       = IdentfierGenerator.new(1,1, self._states.values)
      @_instruction_id_generator = IdentfierGenerator.new(1,1, self._states.values.map{|state| state._instructions.values}.flatten)
    end

    def _add_new_register(register_class, name, klass, type, value)
      new_id   = @_register_id_generator.update
      register = register_class.new(new_id, name, klass, type, value)
      return self._add_register(register)
    end

    def _add_new_resource(resource_class, input_types, output_types, params, option)
      new_id   = @_resource_id_generator.update
      resource = resource_class.new(new_id, input_types, output_types, params, option)
      return self._add_resource(resource)
    end

    def _add_new_state(state_class, name, instruction_list)
      new_id   = @_state_id_generator.update
      state    = state_class.new(new_id, name, instruction_list)
      return self._add_state(state)
    end

  end

  module IState

    def _add_new_instruction(instruction_class, res_class, res_id, op_resources, next_states, input_registers, output_registers)
      new_id      = self._owner_table._instruction_id_generator.update
      instruction = instruction_class.new(new_id, res_class, res_id, op_resources, next_states, input_registers, output_registers)
      return self._add_instruction(instruction)
    end
  end

  module IChannel
  end
  
  module IRegister
  end
  
  module IResource
  end
  
  module IInstruction
  end

  module IType
  end

  module IParams
  end

end
