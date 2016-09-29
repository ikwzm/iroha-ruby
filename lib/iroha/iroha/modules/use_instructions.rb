

module Iroha
  module Modules
  end
end

module Iroha::Modules::UseInstructions

  module IResource
    attr_accessor :_use_instructions
  end

  module IRegister
    attr_accessor :_get_instructions
    attr_accessor :_set_instructions
  end

  module IModule
    def _update_use_instructions
      @_tables.each do |table|
        table._update_use_instructions
      end
    end
  end

  module ITable
    def _update_use_instructions
      @_registers.each{|register| register._get_instructions = [];
                                  register._set_instructions = []}
      @_resources.each{|resource| resource._use_instructions = []}
      @_states.each do |state|
        state._set_use_instructions
      end
      @_registers.each{|register| register._get_instructions.uniq!;
                                  register._set_instructions.uniq!}
      @_resources.each{|resource| resource._use_instructions.uniq!}
    end
  end

  module IState
    def _set_use_instructions
      @_instructions.each do |insn|
        insn._set_register_use_instructions
        insn._set_resource_use_instructions
      end
    end
  end

  module IInstruction
    def _set_register_use_instructions
      @_input_registers.each  do |reg_id|
        register = @_owner_table._find_register(reg_id)
        register._get_instructions.push(@_id)
      end
      @_output_registers.each do |reg_id|
        register = @_owner_table._find_register(reg_id)
        register._set_instructions.push(@_id)
      end
    end
    def _set_resource_use_instructions
      resource = @_owner_table._find_resource(@_res_id)
      resource._use_instructions.push(@_id)
    end
  end

end
