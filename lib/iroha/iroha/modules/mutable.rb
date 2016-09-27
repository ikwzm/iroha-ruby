require_relative './addable'

module Iroha::Modules::Mutable

  def self._reallocate_id(table, new_id_table)
    new_id    = 1
    new_table = Hash.new
    immutable = Hash.new
    table.values.each do |item|
      immutable[item._id] = (item._immutable == true)
    end
    table.values.each do |item|
      old_id = item._id
      if immutable[item._id] != true then
        while immutable[new_id] do new_id = new_id + 1; end
        item._id = new_id
        new_id   = new_id + 1
      end
      new_table[ item._id] = item
      new_id_table[old_id] = item._id
    end
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
      self._modules  = Iroha::Modules::Mutable._reallocate_id(self._modules , Hash.new)
      _add_new_module_id_initialize
    end

    def _reallocate_channels_id
      self._channels = Iroha::Modules::Mutable._reallocate_id(self._channels, Hash.new)
      _add_new_channel_id_initialize
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
      self._tables = Iroha::Modules::Mutable._reallocate_id(self._tables, Hash.new)
      _add_new_table_id_initialize
    end

  end

  module IResource
    attr_writer   :_id
    attr_accessor :_immutable
  end
  
  module IRegister
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
      new_resources = Iroha::Modules::Mutable._reallocate_id(self._resources, new_id_table)
      self._states.values.each do |state|
        state._instructions.values.each do |insn|
          insn._res_id = new_id_table[insn._res_id]
        end
      end
      self._resources = new_resources
      _add_new_resource_id_initialize
    end

    def _reallocate_registers_id
      new_id_table  = Hash.new
      new_registers = Iroha::Modules::Mutable._reallocate_id(self._registers, new_id_table)
      self._states.values.each do |state|
        state._instructions.values.each do |insn|
          insn._input_registers  = insn._input_registers .map{|id| new_id_table[id]}
          insn._output_registers = insn._output_registers.map{|id| new_id_table[id]}
        end
      end
      self._registers = new_registers
      _add_new_register_id_initialize
    end

    def _reallocate_states_id
      new_states   = Iroha::Modules::Mutable._reallocate_id(self._states, Hash.new)
      self._states = new_states
      _add_new_state_id_initialize
    end
    
    def _reallocate_instructions_id
      new_id = 1
      self._states.values.each do |state|
        new_instructions = Hash.new
        state._instructions.values.each do |insn|
          insn._id = new_id
          new_id   = new_id + 1
          new_instructions[insn._id] = insn
        end
        state._instructions = new_instructions
      end
      @_add_new_instruction_id = new_id
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
    attr_writer :_id, :_res_id, :_next_states, :_input_registers, :_output_registers
  end
  
end