module Iroha

  class ITable
    attr_reader :_id, :_name, :_resources, :_registers, :_states, :_init_state_id
    attr_reader :_owner_design, :_owner_module

    def initialize(id, name, resource_list, register_list, state_list, init_state_id)
      @_owner_design  = nil              ## TYPE: Iroha::Design
      @_owner_module  = nil              ## TYPE: Iroha::IModule
      @_id            = id               ## TYPE: number
      _set_name(name)                    ## TYPE: symbol or number or nil
      @_resources     = Hash.new         ## TYPE: Hash {id:number, resource:Iroha::IResource}
      @_registers     = Hash.new         ## TYPE: Hash {id:number, register:Iroha::IRegister}
      @_states        = Hash.new         ## TYPE: Hash {id:number, state   :Iroha::IState   }
      @_init_state_id = init_state_id    ## TYPE: number
      resource_list.each {|resource| _add_resource(resource)}
      register_list.each {|register| _add_register(register)}
      state_list   .each {|state   | _add_state(   state   )}
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

    def _add_resource(resource)
      abort "(RESOURCE #{resource._id} ... ) is multi definition." if @_resources.key?(resource._id)
      @_resources[resource._id] = resource
      resource._set_owner(@_owner_design, @_owner_module, self)
      return resource
    end

    def _add_register(register)
      abort "(REGISTER #{register._id} ... ) is multi definition." if @_registers.key?(register._id)
      @_registers[register._id] = register
      register._set_owner(@_owner_design, @_owner_module, self)
      return register
    end

    def _add_state(state)
      abort "(STATE #{state._id} ... ) is multi definition." if @_states.key?(state._id)
      @_states[state._id] = state
      state._set_owner(@_owner_design,  @_owner_module, self)
      return state
    end
    
    def _set_owner(owner_design, owner_module)
      @_owner_design = owner_design
      @_owner_module = owner_module
      @_registers.values.each{|e| e._set_owner(owner_design, owner_module, self)}
      @_resources.values.each{|e| e._set_owner(owner_design, owner_module, self)}
      @_states.values.each   {|e| e._set_owner(owner_design, owner_module, self)}
    end

    def _find_resource(res_id)
      return @_resources[res_id]
    end
    
    def _find_register(reg_id)
      return @_registers[reg_id]
    end
    
    def _id_to_str
      if @_owner_module.nil? == false then
        module_str = @_owner_module._id_to_str
      else
        module_str = "UnknownModule"
      end
      return module_str + "::ITable[#{@_id}]"
    end

    def _to_exp(indent)
      return indent + "(TABLE #{@_id}" + ((@_name != nil) ? " #{@_name}" : " ()") + "\n" +
             ((@_registers.size > 0)?
                (indent + "  (REGISTERS\n" + @_registers.values.map{|reg| reg._to_exp(indent+"    ")}.join("\n") + "\n" + indent + "  )\n") :
                (indent + "  (REGISTERS)\n")) +
             ((@_resources.size > 0)?
                (indent + "  (RESOURCES\n" + @_resources.values.map{|res| res._to_exp(indent+"    ")}.join("\n") + "\n" + indent + "  )\n") :
                (indent + "  (RESOURCES)\n")) +
             ((@_states.size > 0)?
                (indent + "  (INITIAL #{@_init_state_id})\n") : "") + 
             ((@_states.size > 0)?
                (@_states.values.map{|state| state._to_exp(indent+"  ")}.join("\n") + "\n") : "") +
             indent + ")"
    end

    def self.convert_from(table)
      parent_class   = Iroha.parent_class(self)
      resource_class = parent_class.const_get(:IResource)
      register_class = parent_class.const_get(:IRegister)
      state_class    = parent_class.const_get(:IState   )
      id             = table._id
      name           = table._name
      resource_list  = table._resources.values.map{|resource| resource_class.convert_from(resource)}
      register_list  = table._registers.values.map{|register| register_class.convert_from(register)}
      state_list     = table._states   .values.map{|state   | state_class   .convert_from(state   )}
      init_state_id  = table._init_state_id
      self.new(id, name, resource_list, register_list, state_list, init_state_id)
    end

  end

end
