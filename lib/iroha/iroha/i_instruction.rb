module Iroha

  class IInstruction

    attr_reader :_id, :_res_class, :_res_id, :_op_resources, :_next_states, :_input_registers, :_output_registers
    attr_reader :_owner_design, :_owner_module, :_owner_table, :_owner_state

    def initialize(id, res_class, res_id, op_resources, next_states, input_registers, output_registers)
      @_id               = id                ## TYPE: number
      @_res_class        = res_class         ## TYPE: string
      @_res_id           = res_id            ## TYPE: number
      @_op_resources     = op_resources      ## TYPE: Array[resource_id:number]
      @_next_states      = next_states       ## TYPE: Array[state_id:number]
      @_input_registers  = input_registers   ## TYPE: Array[register_id:number]
      @_output_registers = output_registers  ## TYPE: Array[register_id:number]
      @_owner_design     = nil
      @_owner_module     = nil
      @_owner_table      = nil
      @_owner_state      = nil
    end

    def _set_owner(owner_design, owner_module, owner_table, owner_state)
      @_owner_design     = owner_design
      @_owner_module     = owner_module
      @_owner_table      = owner_table
      @_owner_state      = owner_state
    end

    def _to_exp(indent)
      abort "Undefined Owner Table at (INSN #{@_id} ...)" if @_owner_table.nil?
      op_res      = "(" + @_op_resources    .map{|op| op                              }.join(" ") + ")"
      next_states = "(" + @_next_states     .map{|id| @_owner_table._states[   id]._id}.join(" ") + ")"
      input_regs  = "(" + @_input_registers .map{|id| @_owner_table._registers[id]._id}.join(" ") + ")"
      output_regs = "(" + @_output_registers.map{|id| @_owner_table._registers[id]._id}.join(" ") + ")"
      return indent + "(INSN #{@_id} #{@_res_class} #{@_res_id} #{op_res} #{next_states} #{input_regs} #{output_regs})"
    end

    def _id_to_str
      if @_owner_state.nil? == false then
        state_str = @_owner_state._id_to_str
      else
        state_str = "UnknownState"
      end
      return state_str + "::Instruction[#{@_id}]"
    end

    def self.convert_from(insn)
      id               = insn._id
      res_class        = insn._res_class.clone
      res_id           = insn._res_id
      op_resources     = insn._op_resources.clone
      next_states      = insn._next_states.clone
      input_registers  = insn._input_registers.clone
      output_registers = insn._output_registers.clone
      self.new(id, res_class, res_id, op_resources, next_states, input_registers, output_registers)
    end
    
  end

end
