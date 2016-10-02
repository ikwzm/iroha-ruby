require_relative './addable'

module Iroha
  module Modules
  end
end

module Iroha::Modules::Mutable

  def self._reallocate_id(id_gen, table, new_id_table)
    id_gen.reset([])
    new_table = Hash.new
    immutable = Hash.new
    table.values.each do |item|
      immutable[item._id] = (item._immutable == true)
    end
    table.values.each do |item|
      old_id = item._id
      if immutable[item._id] != true then
        new_id = id_gen.update
        while immutable[new_id] do
          new_id = id_gen.update
        end
        item._id = new_id
      end
      new_table[ item._id] = item
      new_id_table[old_id] = item._id
    end
    id_gen.reset(new_table.values)
    return new_table
  end

  module IDesign

    include Iroha::Modules::Addable::IDesign

    attr_writer   :_modules, :_channels
    attr_accessor :_immutable

    def _delete_module(mod)
      self._modules.delete(mod._id)
      return mod
    end

    def _delete_channel(channel)
      self._channels.delete(channel._id)
      return channel
    end
    
    def _reallocate_modules_id
      self._modules  = Iroha::Modules::Mutable._reallocate_id(self._module_id_generator , self._modules , Hash.new)
    end

    def _reallocate_channels_id
      self._channels = Iroha::Modules::Mutable._reallocate_id(self._channel_id_generator, self._channels, Hash.new)
    end

  end

  module IModule

    include Iroha::Modules::Addable::IModule

    attr_writer   :_id, :_tables
    attr_accessor :_immutable

    def _delete_table(table)
      self._tables.delete(table._id)
      return table
    end

    def _reallocate_tables_id
      self._tables = Iroha::Modules::Mutable._reallocate_id(self._table_id_generator, self._tables, Hash.new)
    end

  end

  module IResource
    include Iroha::Modules::Addable::IResource
    attr_writer   :_id
    attr_accessor :_immutable
  end
  
  module IRegister
    include Iroha::Modules::Addable::IRegister
    attr_writer   :_id
    attr_accessor :_immutable
  end
  
  module ITable
    include Iroha::Modules::Addable::ITable

    attr_writer   :_id, :_registers, :_resources, :_states
    attr_accessor :_immutable

    def _delete_register(register)
      self._registers.delete(register._id)
      return register
    end

    def _delete_resource(resource)
      self._resources.delete(resource._id)
      return resource
    end

    def _delete_state(state)
      self._states.delete(state._id)
      return state
    end

    def _reallocate_resources_id
      new_id_table  = Hash.new
      new_resources = Iroha::Modules::Mutable._reallocate_id(self._resource_id_generator, self._resources, new_id_table)
      self._states.values.each do |state|
        state._instructions.values.each do |insn|
          insn._res_id = new_id_table.fetch(insn._res_id, insn._res_id)
        end
      end
      self._resources = new_resources
    end

    def _reallocate_registers_id
      new_id_table  = Hash.new
      new_registers = Iroha::Modules::Mutable._reallocate_id(self._register_id_generator, self._registers, new_id_table)
      self._states.values.each do |state|
        state._instructions.values.each do |insn|
          insn._input_registers  = insn._input_registers .map{|id| new_id_table.fetch(id, id)}
          insn._output_registers = insn._output_registers.map{|id| new_id_table.fetch(id, id)}
        end
      end
      self._registers = new_registers
    end

    def _reallocate_states_id
      self._states  = Iroha::Modules::Mutable._reallocate_id(self._state_id_generator, self._states, Hash.new)
    end
    
    def _reallocate_instructions_id
      self._instruction_id_generator.reset([])
      self._states.values.each do |state|
        new_instructions = Hash.new
        state._instructions.values.each do |insn|
          insn._id = self._instruction_id_generator.update
          new_instructions[insn._id] = insn
        end
        state._instructions = new_instructions
      end
    end

  end
  
  module IState

    include Iroha::Modules::Addable::IState

    attr_writer   :_id, :_instructions
    attr_accessor :_immutable
    
    def _delete_instruction(instruction)
      self._instructions.delete(instruction._id)
      return instruction
    end

  end

  module IInstruction
    include Iroha::Modules::Addable::IInstruction
    attr_writer :_id, :_res_id, :_next_states, :_input_registers, :_output_registers
  end
  
  module IChannel
    include Iroha::Modules::Addable::IChannel
  end

  module IType
    include Iroha::Modules::Addable::IType
  end

  module IParams
    include Iroha::Modules::Addable::IParams
  end

end
