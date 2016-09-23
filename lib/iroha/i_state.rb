module Iroha

  class IState
    attr_reader :_id, :_name, :_instructions
    attr_reader :_owner_design, :_owner_module, :_owner_table

    def initialize(id, name, instruction_list)
      @_owner_design  = nil              ## TYPE: Iroha::Design
      @_owner_module  = nil              ## TYPE: Iroha::IModule
      @_owner_table   = nil              ## TYPE: Iroha::Table
      @_id            = id               ## TYPE: number
      _set_name(name)                    ## TYPE: symbol or number or nil
      @_instructions  = Hash.new         ## TYPE: Hash {id:number, insn:Iroha::IInstruction}
      instruction_list.each {|insn| _add_instruction(insn)}
    end

    def _set_name(name)
      if name.class == String then
        if name == "" then
          @_name = nil
        else
          @_name = name.to_sym
        end
      else
          @_name = name
      end
      return @_name
    end

    def _add_instruction(insn)
      abort "(INSN #{insn._id} ... ) is multi definition." if @_instructions.key?(insn._id)
      @_instructions[insn._id] = insn
      insn._set_owner(@_owner_design,  @_owner_module, @_owner_table, self)
      return insn
    end

    def _set_owner(owner_design, owner_module, owner_table)
      @_owner_design = owner_design
      @_owner_module = owner_module
      @_owner_table  = owner_table
      @_instructions.values.each{|insn| insn._set_owner(owner_design, owner_module, owner_table, self)}
    end

    def _id_to_str
      if @_owner_table.nil? == false then
        table_str = @_owner_table._id_to_str
      else
        table_str = "UnknownTable"
      end
      return table_str + "::IState[{#@_id}]"
    end

    def _to_exp(indent)
      if @_instructions.size == 0 then
        return indent + "(STATE #{@_id})"
      else
        return indent + "(STATE #{@_id}\n" +
               @_instructions.values.map{|insn| insn._to_exp(indent+"  ")}.join("\n") + "\n" +
               indent + ")"
      end
    end

    def self.convert_from(state)
      parent_class      = Iroha.parent_class(self)
      id                = state._id
      name              = state._name
      instruction_class = parent_class.const_get(:IInstruction)
      instruction_list  = state._instructions.values.map{|insn| instruction_class.convert_from(insn)}
      self.new(id, name, instruction_list)
    end

  end

end
