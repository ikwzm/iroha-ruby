module Iroha

  class ITable
    attr_reader :id, :name, :resources, :registers, :states, :init_state_id
    attr_reader :owner_design, :owner_module

    def initialize(id, name, resource_list, register_list, state_list, init_state_id)
      @owner_design  = nil              ## TYPE: Iroha::Design
      @owner_module  = nil              ## TYPE: Iroha::IModule
      @id            = id               ## TYPE: number
      set_name(name)                    ## TYPE: symbol or number or nil
      @resources     = Hash.new         ## TYPE: Hash {id:number, resource:Iroha::IResource}
      @registers     = Hash.new         ## TYPE: Hash {id:number, register:Iroha::IRegister}
      @states        = Hash.new         ## TYPE: Hash {id:number, state   :Iroha::IState   }
      @init_state_id = init_state_id    ## TYPE: number
      resource_list.each {|resource| add_resource(resource)}
      register_list.each {|register| add_register(register)}
      state_list.each    {|state   | add_state(   state   )}
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

    def add_resource(resource)
      abort "(RESOURCE #{resource.id} ... ) is multi definition." if @resources.key?(resource.id)
      @resources[resource.id] = resource
      resource.set_owner(@owner_design, @owner_module, self)
      return resource
    end

    def add_register(register)
      abort "(REGISTER #{register.id} ... ) is multi definition." if @registers.key?(register.id)
      @registers[register.id] = register
      register.set_owner(@owner_design, @owner_module, self)
      return register
    end

    def add_state(state)
      abort "(STATE #{state.id} ... ) is multi definition." if @states.key?(state.id)
      @states[state.id] = state
      state.set_owner(@owner_design,  @owner_module, self)
      return state
    end
    
    def set_owner(owner_design, owner_module)
      @owner_design = owner_design
      @owner_module = owner_module
      @registers.values.each{|e| e.set_owner(owner_design, owner_module, self)}
      @resources.values.each{|e| e.set_owner(owner_design, owner_module, self)}
      @states.values.each   {|e| e.set_owner(owner_design, owner_module, self)}
    end

    def find_resource(res_id)
      return @resources[res_id]
    end
    
    def to_exp(indent)
      return indent + "(TABLE #{@id}\n" +
             ((@registers.size > 0)?
                (indent + "  (REGISTERS\n" + @registers.values.map{|reg| reg.to_exp(indent+"    ")}.join("\n") + "\n" + indent + "  )\n") :
                (indent + "  (REGISTERS)\n")) +
             ((@resources.size > 0)?
                (indent + "  (RESOURCES\n" + @resources.values.map{|res| res.to_exp(indent+"    ")}.join("\n") + "\n" + indent + "  )\n") :
                (indent + "  (RESOURCES)\n")) +
             ((@states.size > 0)?
                (indent + "  (INITIAL #{@init_state_id})\n") : "") + 
             ((@states.size > 0)?
                (@states.values.map{|state| state.to_exp(indent+"  ")}.join("\n") + "\n") : "") +
             indent + ")"
    end

    def self.convert_from(table)
      parent_class   = Iroha.parent_class(self)
      resource_class = parent_class.const_get(:IResource)
      register_class = parent_class.const_get(:IRegister)
      state_class    = parent_class.const_get(:IState   )
      id             = table.id
      name           = table.name
      resource_list  = table.resources.values.map{|resource| resource_class.convert_from(resource)}
      register_list  = table.registers.values.map{|register| register_class.convert_from(register)}
      state_list     = table.states.values.map   {|state   | state_class.convert_from(   state   )}
      init_state_id  = table.init_state_id
      self.new(id, name, resource_list, register_list, state_list, init_state_id)
    end

  end

end
