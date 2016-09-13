module Iroha

  class IState
    attr_reader :id, :name, :instructions
    attr_reader :owner_design, :owner_module, :owner_table

    def initialize(id, name, instruction_list)
      @owner_design  = nil              ## TYPE: Iroha::Design
      @owner_module  = nil              ## TYPE: Iroha::IModule
      @owner_table   = nil              ## TYPE: Iroha::Table
      @id            = id               ## TYPE: number
      set_name(name)                    ## TYPE: symbol or number or nil
      @instructions  = Hash.new         ## TYPE: Hash {id:number, insn:Iroha::IInstruction}
      instruction_list.each {|insn| add_instruction(insn)}
    end

    def set_name(name)
      if name.class == String then
        if name == "" then
          @name = nil
        else
          @name = name.to_sym
        end
      else
          @name = name
      end
      return @name
    end

    def add_instruction(insn)
      abort "(INSN #{insn.id} ... ) is multi definition." if @instructions.key?(insn.id)
      @instructions[insn.id] = insn
      insn.set_owner(@owner_design,  @owner_module, @owner_table, self)
      return insn
    end

    def set_owner(owner_design, owner_module, owner_table)
      @owner_design = owner_design
      @owner_module = owner_module
      @owner_table  = owner_table
      @instructions.values.each{|insn| insn.set_owner(owner_design, owner_module, owner_table, self)}
    end

    def id_to_str
      if @owner_table != nil
        table_str = @owner_table.id_to_str
      else
        table_str = "UnknownTable"
      end
      return table_str + "::IState[{#@id}]"
    end

    def to_exp(indent)
      if @instructions.size == 0 then
        return indent + "(STATE #{@id})"
      else
        return indent + "(STATE #{@id}\n" +
               @instructions.values.map{|insn| insn.to_exp(indent+"  ")}.join("\n") + "\n" +
               indent + ")"
      end
    end

    def self.convert_from(state)
      parent_class      = Iroha.parent_class(self)
      id                = state.id
      name              = state.name
      instruction_class = parent_class.const_get(:IInstruction)
      instruction_list  = state.instructions.values.map{|insn| instruction_class.convert_from(insn)}
      self.new(id, name, instruction_list)
    end

  end

end
