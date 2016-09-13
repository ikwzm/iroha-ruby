module Iroha

  class IInstruction

    attr_reader :id, :res_class, :res_id, :op_resources, :next_states, :input_registers, :output_registers
    attr_reader :owner_design, :owner_module, :owner_table, :owner_state

    def initialize(id, res_class, res_id, op_resources, next_states, input_registers, output_registers)
      @id               = id                ## TYPE: number
      @res_class        = res_class         ## TYPE: string
      @res_id           = res_id            ## TYPE: number
      @op_resources     = op_resources      ## TYPE: Array[resource_id:number]
      @next_states      = next_states       ## TYPE: Array[state_id:number]
      @input_registers  = input_registers   ## TYPE: Array[register_id:number]
      @output_registers = output_registers  ## TYPE: Array[register_id:number]
      @owner_design     = nil
      @owner_module     = nil
      @owner_table      = nil
      @owner_state      = nil
    end

    def set_owner(owner_design, owner_module, owner_table, owner_state)
      @owner_design     = owner_design
      @owner_module     = owner_module
      @owner_table      = owner_table
      @owner_state      = owner_state
    end

    def to_exp(indent)
      abort "Undefined Owner Table at (INSN #{@id} ...)" if @owner_table == nil
      op_res      = "(" + @op_resources.map{    |op| op                           }.join(" ") + ")"
      next_states = "(" + @next_states.map{     |id| @owner_table.states[   id].id}.join(" ") + ")"
      input_regs  = "(" + @input_registers.map{ |id| @owner_table.registers[id].id}.join(" ") + ")"
      output_regs = "(" + @output_registers.map{|id| @owner_table.registers[id].id}.join(" ") + ")"
      return indent + "(INSN #{@id} #{@res_class} #{@res_id} #{op_res} #{next_states} #{input_regs} #{output_regs})"
    end

    def id_to_str
      if @owner_state != nil then
        state_str = @owner_state.id_to_str
      else
        state_str = "UnknownState"
      end
      return state_str + "::Instruction[#{id}]"
    end

    def self.convert_from(insn)
      id               = insn.id
      res_class        = insn.res_class.clone
      res_id           = insn.res_id
      op_resources     = insn.op_resources.clone
      next_states      = insn.next_states.clone
      input_registers  = insn.input_registers.clone
      output_registers = insn.output_registers.clone
      self.new(id, res_class, res_id, op_resources, next_states, input_registers, output_registers)
    end
    
  end

end
