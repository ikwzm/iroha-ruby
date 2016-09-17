require_relative '../../iroha'

module Iroha
  module Builder
    module Simple
      Iroha.franchise_class(Iroha,self)
    end
  end
end

module Iroha::Builder::Simple

  module Work
  end

  def   IDesign(name, &block)
    design_class = Work.const_set(name.capitalize, Class.new(Iroha::Builder::Simple::IDesign))
    design_class.new(&block)
  end

  class IDesign

    def initialize(&block)
      super
      @_module_last_id  = 1
      @_channel_last_id = 1
      if block_given? then
        self.instance_eval(&block)
      end
      _resolve_reference()
      return self
    end

    def _resolve_reference
      @_modules.each_pair{|id, mod| mod._resolve_reference}
    end

    def __add_module(name, parent_id, &block)
      params       = Iroha::Builder::Simple::IParams.new
      tables       = []
      module_class = self.class.const_set(name.capitalize, Class.new(Iroha::Builder::Simple::IModule))
      module_inst  = module_class.new(@_module_last_id, name, parent_id, params, tables)
      @_module_last_id = @_module_last_id+1
      self.class.send(:define_method, module_inst._name, Proc.new do module_inst; end)
      _add_module(module_inst)
      if block_given? then
        module_inst.instance_eval(&block)
      end
      return module_inst
    end

    def __add_channel(channel_write, channel_read)
      channel = IChannel.new(@_channel_last_id,
                             channel_write._input_types[0],
                             channel_write._owner_module._id,
                             channel_write._owner_table._id,
                             channel_write._id,
                             channel_read._owner_module._id,
                             channel_read._owner_table._id,
                             channel_read._id)
      @_channel_last_id = @_channel_last_id+1
      _add_channel(channel)
      return channel
    end

    def IModule(name, &block)
      return __add_module(name, nil, &block)
    end

  end

  class IModule

    def initialize(id, name, parent_id, params, table_list)
      super
      @_table_last_id = 1
    end

    def __add_table(table)
      _add_table(table)
      self.class.send(:define_method, table._name, Proc.new do table; end)
    end

    def ITable(name, &block)
      table_class     = self.class.const_set(name.capitalize, Class.new(Iroha::Builder::Simple::ITable))
      table           = table_class.new(@_table_last_id, name, [], [], [], nil)
      @_table_last_id = @_table_last_id+1
      __add_table(table)
      if block_given? then
        table.instance_eval(&block)
      end
      return table
    end

    def IModule(name, &block)
      return @_owner_design.__add_module(name, @_id, &block)
    end

    def _resolve_reference
      @_tables.each_pair{|id, table| table._resolve_reference}
    end

  end
      
  class Reference
    attr_reader :root, :args
    def initialize(root, args)
      @root = root
      @args = args
    end
    def resolve
      element = root
      @args.each do |ref|
        element = element.send(ref)
      end
      return element
    end
  end

  class ITable
    attr_reader   :_init_state_id

    def initialize(id, name, resource_list, register_list, state_list, init_state_id)
      super(id, name, resource_list, register_list, state_list, init_state_id)
      @_register_last_id  = 1
      @_resource_last_id  = 1
      @_state_last_id     = 1
      @_insn_last_id      = 1
      @_singleton_classes = Hash.new
      @_state_class       = self.class.const_set(:State, Class.new(Iroha::Builder::Simple::IState))
      @_on_state          = nil
    end

    def __add_state(state)
      _add_state(state)
      self   .class.send(:define_method, state._name, Proc.new do state; end)
      @_state_class.send(:define_method, state._name, Proc.new do state; end)
    end

    def IState(name, &block)
      state = @_state_class.new(@_state_last_id, name, [])
      @_state_last_id = @_state_last_id + 1
      if @_init_state_id == nil
        @_init_state_id = state._id
      end
      __add_state(state)
      if block_given? then
        _state_entry(state)
        state.instance_eval(&block)
        _state_exit
      end
      return state
    end

    def Resource(class_name, name, input_types, output_types, params, option)
      return __add_resource(class_name, name, input_types, output_types, params, option)
    end

    def Register(name, type)
      return __add_register(name, :REG  , type)
    end
        
    def Constant(name, type)
      return __add_register(name, :CONST, type)
    end

    def Wire(name, type)
      return __add_register(name, :WIRE , type)
    end

    def Unsigned(width)
      return IValueType.new(false, width)
    end

    def Signed(width)
      return IValueType.new(true , width)
    end

    def Ref(*args)
      return Reference.new(@_owner_design, args)
    end

    def _state_entry(state)
      @_on_state = state
    end

    def _state_exit
      @_on_state = nil
    end

    def _on_state
      if @_on_state.class == @_state_class then
        return @_on_state
      else
        return nil
      end
    end

    def _resolve_reference()
      @_resources.values.each do |resource|
        if resource.class.method_defined?(:_resolve_reference) then
          resource._resolve_reference()
        end
      end
    end

    def __add_register(name, klass, type)
      fail "Error: illegal type(#{type.class})" if type.class != IValueType
      register = IRegister.new(@_register_last_id, name, klass, type, type._assign_value)
      @_register_last_id = @_register_last_id + 1
      _add_register(register)
      if name.class == Symbol then
        self.class.send(   :define_method, name, Proc.new do register; end)
        @_state_class.send(:define_method, name, Proc.new do register; end)
      end
      return register
    end

    def __add_resource(class_name, name, input_types, output_types, params, option)
      res_params = IParams.new
      res_params.update(params)
      resource_class = IResource.const_get(class_name)
      if resource_class.const_defined?(:SINGLETON) and @_singleton_classes.key?(class_name) then
        resource = @_singleton_classes[class_name]
      else
        resource = resource_class.new(@_resource_last_id, input_types, output_types, res_params, option)
        @_resource_last_id = @_resource_last_id + 1
        _add_resource(resource)
      end
      if resource_class.const_defined?(:SINGLETON) then
        @_singleton_classes[class_name] = resource
      end
      if name.class == Symbol then
        self.class.send(  :define_method, name, Proc.new do resource; end)
        if resource.class.const_defined?(:INSTANCE_OPERATOR) and resource.class.const_get(:INSTANCE_OPERATOR) then
          @_state_class.send(:define_method, name, Proc.new{|*regs| Operator.new(resource, regs)})
        else
          @_state_class.send(:define_method, name, Proc.new do resource; end)
        end
      end
      return resource
    end

    def __add_instruction(resource, op_resources, next_states, input_registers, output_registers)
      insn = IInstruction.new(@_insn_last_id,
                              resource._class_name,
                              resource._id,
                              op_resources,
                              next_states     .map{|state   | state._id   },
                              input_registers .map{|register| register._id},
                              output_registers.map{|register| register._id})
      @_insn_last_id = @_insn_last_id + 1
      return insn
    end

  end

  class Operator
    attr_reader :op, :operand
    def initialize(op, operand)
      @op      = op
      @operand = operand
    end
  end

  class IRegister
    def self.clone(register)
      if register.class == IRegister then
        return IRegister.convert_from(register)
      else
        fail "IRegister.clone(#{register.class})"
      end
    end

    define_method('=>') do |regs|
      state = @_owner_table._on_state
      fail "Error: not on state"           if state      == nil
      fail "Error: source is not register" if regs.class != IRegister
      resource = @_owner_table.__add_resource(:Set, nil, [self._type] , [regs._type],{},{})
      insn     = state.__add_instruction(resource,[],[], [self      ] , [regs      ]      )
      return self
    end

    define_method('<=') do |value|
      state = @_owner_table._on_state
      if state != nil then
        if @_class == :CONST then
          fail "Error: Can not set data to Constant({#self._name}) on State(state._name)"
        end
        dst = IRegister.clone(self)
        if value.class.method_defined?(:'=>') then
          value.send(:'=>', dst)
          return dst
        elsif value.class == Operator then
          src       = value
          src_types = src.operand.map{|regs| regs._type}
          if src.op.class == Symbol then
            resource= @_owner_table.__add_resource(src.op ,nil, src_types  , [dst._type],{},{})
            insn    = state.__add_instruction(resource, [], [], src.operand, [dst      ]      )
          else
            resource= src.op
            insn    = state.__add_instruction(resource, [], [], src.operand, [dst      ]      )
          end
        else
          fail "Error: illegal source value #{value.class}"
        end
        return dst
      else
        _set_value(value)
        return self
      end
    end
  end

  class IState

    def __add_instruction(resource, op_resources, next_states, input_registers, output_registers)
      ## p "add_instruction(#{resource}, op_resources, next_states, #{input_registers.map{|r|r._id}}, #{output_registers.map{|r|r._id}})"
      insn = @_owner_table.__add_instruction(resource, op_resources, next_states, input_registers, output_registers)
      _add_instruction(insn)
      return insn
    end

    def _insn(resource, op_resources, next_states, input_registers, output_registers)
      __add_instruction(resource, op_resources, next_states, input_registers, output_registers)
    end

    def on( &block )
      if block_given? then
        @_owner_table._state_entry(self)
        self.instance_eval(&block)
        @_owner_table._state_exit
      end
    end

    def Case(cond_regs, &block)
      if block_given? then
        next_states = self.instance_eval(&block)
        if next_states.class == Hash then
          next_state_list = Array.new
          next_states.each_pair do |num, next_state|
            next_state_list[num] = next_state
          end
        else
          next_state_list = next_states
        end
      else
        next_state_list = []
      end
      resource = @_owner_table.__add_resource(:Transition, nil, [], [], {}, {})
      __add_instruction(resource, [], next_state_list, [cond_regs], [])
    end

    def Goto(next_state)
      resource = @_owner_table.__add_resource(:Transition, nil, [], [], {}, {})
      __add_instruction(resource, [], [next_state   ], [         ], [])
    end

    def To_Unsigned(value, width)
      type = IValueType.new(false, width)
      type._assign_value = value
      return @_owner_table.__add_register(nil, :CONST, type)
    end

    def To_Signed(value, width)
      type = IValueType.new(true , width)
      type._assign_value = value
      return @_owner_table.__add_register(nil, :CONST, type)
    end

  end

  class IValueType
    attr_accessor :_assign_value
    def initialize(is_signed, width)
      super
      @_assign_value = nil
    end

    define_method('<=') do |value|
      @_assign_value = value
      return self
    end
    
  end

  class IResource

    def self.convert_from(resource)
      res_class = resource.class.to_s.split(/::/).last
      Iroha::Builder::Simple::IResource.const_get(res_class).convert_from(resource)
    end

    class ExtInput
      RESOURCE_PROC     = Proc.new{|name, width| __add_resource(__method__, name, [], [], {INPUT:  name, WIDTH: width}, {})}
      define_method('=>') do |regs|
        state = @_owner_table._on_state
        fail "Error: not on state"           if state      == nil
        fail "Error: source is not register" if regs.class != IRegister
        state.__add_instruction(self, [], [], [], [regs])
        return self
      end
    end

    class ExtOutput
      RESOURCE_PROC     = Proc.new{|name, width| __add_resource(__method__, name, [], [], {OUTPUT: name, WIDTH: width}, {})}
      define_method('<=') do |regs|
        state = @_owner_table._on_state
        fail "Error: not on state"           if state      == nil
        fail "Error: source is not register" if regs.class != IRegister
        state.__add_instruction(self, [], [], [regs], [])
        return self
      end
    end

    class PortInput
      attr_accessor :_ref_resources
      RESOURCE_PROC = Proc.new do |name, type, *resources|
        params = {:INPUT => name, :WIDTH => type._width}
        resource = __add_resource(__method__, name, [], [type], params, {:"PORT-INPUT" => nil})
        resource._ref_resources = resources
        return resource
      end
      def _resolve_reference
        @_ref_resources.each do |ref|
          if ref.class == Reference then
            resource = ref.resolve()
          else
            resource = ref
          end
          if resource == nil then
            fail "Error: can not found register Reference(#{ref.args})"
          end
          _add_connection(resource._owner_module._id, resource._owner_table._id, resource._id)
        end
      end
      define_method('=>') do |regs|
        state = @_owner_table._on_state
        fail "Error: not on state"           if state      == nil
        fail "Error: source is not register" if regs.class != IRegister
        state.__add_instruction(self, [], [], [], [regs])
        return self
      end
      define_method('<=') do |regs|
        fail "Error: can not connect PortOut(#{_id_to_str}) to #{regs._id_to_str}" if regs.class != PortOutput
        self._add_connection(regs._owner_module._id, regs._owner_table._id, regs._id)
        regs._add_connection(self._owner_module._id, self._owner_table._id, self._id)
        return self
      end
    end

    class PortOutput
      attr_accessor :_ref_resources
      RESOURCE_PROC = Proc.new do |name, type, *resources| 
        params = {:OUTPUT => name, :WIDTH => type._width}
        resource = __add_resource(__method__, name, [type], [], params, nil)
        resource._ref_resources = resources
        return resource
      end
      def _resolve_reference
        @_ref_resources.each do |ref|
          if ref.class == Reference then
            resource = ref.resolve
          else
            resource = ref
          end
          if resource == nil then
            fail "Error: can not found register Reference(#{ref.args})"
          end
          _add_connection(resource._owner_module._id, resource._owner_table._id, resource._id)
        end
      end
      define_method('<=') do |regs|
        state = @_owner_table._on_state
        fail "Error: not on state"           if state      == nil
        fail "Error: source is not register" if regs.class != IRegister
        state.__add_instruction(self, [], [], [regs], [])
        return self
      end
    end

    class Add
      BINARY_OPERATOR   = '+'
      INSTANCE_OPERATOR = true
      STATE_PROC        = Proc.new{|*regs| Operator.new(__method__, regs)}
      RESOURCE_PROC     = Proc.new{|name, i_types, o_types| __add_resource(__method__, name, i_types, o_types, {}, {})}
    end
    
    class Sub
      BINARY_OPERATOR   = '-'
      INSTANCE_OPERATOR = true
      STATE_PROC        = Proc.new{|*regs| Operator.new(__method__, regs)}
      RESOURCE_PROC     = Proc.new{|name, i_types, o_types| __add_resource(__method__, name, i_types, o_types, {}, {})}
    end
    
    class Mul
      BINARY_OPERATOR   = '*'
      INSTANCE_OPERATOR = true
      STATE_PROC        = Proc.new{|*regs| Operator.new(__method__, regs)}
      RESOURCE_PROC     = Proc.new{|name, i_types, o_types| __add_resource(__method__, name, i_types, o_types, {}, {})}
    end
      
    class Gt 
      BINARY_OPERATOR   = '>'
      INSTANCE_OPERATOR = true
      STATE_PROC        = Proc.new{|*regs| Operator.new(__method__, regs)}
      RESOURCE_PROC     = Proc.new{|name, i_types, o_types| __add_resource(__method__, name, i_types, o_types, {}, {})}
    end

    class Gte
      BINARY_OPERATOR   = '>='
      INSTANCE_OPERATOR = true
      STATE_PROC        = Proc.new{|*regs| Operator.new(__method__, regs)}
      RESOURCE_PROC     = Proc.new{|name, i_types, o_types| __add_resource(__method__, name, i_types, o_types, {}, {})}
    end

    class Eq 
      BINARY_OPERATOR   = '=='
      INSTANCE_OPERATOR = true
      STATE_PROC        = Proc.new{|*regs| Operator.new(__method__, regs)}
      RESOURCE_PROC     = Proc.new{|name, i_types, o_types| __add_resource(__method__, name, i_types, o_types, {}, {})}
    end

    class BitAnd
      BINARY_OPERATOR   = '&'
      INSTANCE_OPERATOR = true
      STATE_PROC        = Proc.new{|*regs| Operator.new(__method__, regs)}
      RESOURCE_PROC     = Proc.new{|name, i_types, o_types| __add_resource(__method__, name, i_types, o_types, {}, {})}
    end
    
    class BitOr 
      BINARY_OPERATOR   = '|'
      INSTANCE_OPERATOR = true
      STATE_PROC        = Proc.new{|*regs| Operator.new(__method__, regs)}
      RESOURCE_PROC     = Proc.new{|name, i_types, o_types| __add_resource(__method__, name, i_types, o_types, {}, {})}
    end
    
    class BitXor
      BINARY_OPERATOR   = '^'
      INSTANCE_OPERATOR = true
      STATE_PROC        = Proc.new{|*regs| Operator.new(__method__, regs)}
      RESOURCE_PROC     = Proc.new{|name, i_types, o_types| __add_resource(__method__, name, i_types, o_types, {}, {})}
    end
    
    class Shift 
      BINARY_OPERATOR   = '<<'
      INSTANCE_OPERATOR = true
      STATE_PROC        = Proc.new{|*regs| Operator.new(__method__, regs)}
      RESOURCE_PROC     = Proc.new{|name, i_types, o_types| __add_resource(__method__, name, i_types, o_types, {}, {})}
    end
      
    class BitInv
      INSTANCE_OPERATOR = true
      STATE_PROC        = Proc.new{|*regs| Operator.new(__method__, regs)}
      RESOURCE_PROC     = Proc.new{|name, i_types, o_types| __add_resource(__method__, name, i_types, o_types, {}, {})}
    end

    class BitSel 
      INSTANCE_OPERATOR = true
      STATE_PROC        = Proc.new{|*regs| Operator.new(__method__, regs)}
      RESOURCE_PROC     = Proc.new{|name, i_types, o_types| __add_resource(__method__, name, i_types, o_types, {}, {})}
    end

    class BitConcat
      INSTANCE_OPERATOR = true
      STATE_PROC        = Proc.new{|*regs| Operator.new(__method__, regs)}
      RESOURCE_PROC     = Proc.new{|name, i_types, o_types| __add_resource(__method__, name, i_types, o_types, {}, {})}
    end
    
    class Array    
      RESOURCE_PROC     = Proc.new{|name, addr_width, value_type, ownership, mem_type|
        fail "Error Illegal ownership #{ownership} of Array" if (ownership != :EXTERNAL and ownership != :INTERNAL)
        fail "Error Illegal mem type  #{mem_type}  of Array" if (mem_type  != :RAM      and mem_type  != :ROM     )
        is_external = (ownership == :EXTERNAL)
	is_ram      = (mem_type  == :RAM     )
        __add_resource(__method__, name, [], [], {}, {ARRAY: {ADDR_WIDTH: addr_width, VALUE_TYPE: value_type, EXTERNAL: is_external, RAM: is_ram}})
      }
      class Data
        attr_reader :array, :addr
        def initialize(array, addr)
          @array = array
          @addr  = addr
        end
        define_method('<=') do |regs|
          state = @array._owner_table._on_state
          fail "Error: not on state"           if state      == nil
          fail "Error: source is not register" if regs.class != IRegister
          state.__add_instruction(@array, [], [], [@addr,regs],[])
        end
        define_method('=>') do |regs|
          state = @array._owner_table._on_state
          fail "Error: not on state"           if state      == nil
          fail "Error: source is not register" if regs.class != IRegister
          state.__add_instruction(@array, [], [], [@addr], [regs])
          return self
        end
      end
      define_method('[]') do |addr|
        fail "Error: address is not register" if addr.class != IRegister
        return Data.new(self, addr)
      end
    end

    class ForeignReg
      attr_accessor :_ref_regs
      RESOURCE_PROC = Proc.new do |name, regs|
        if    regs.class == IRegister then
          resource = __add_resource(__method__, name, [], [], {}, {:"FOREIGN-REG" => {:MODULE => regs._owner_module._id, :TABLE => regs._owner_table._id, :REGISTER => regs._id}})
          resource._ref_regs = nil
          return resource
        elsif regs.class == Reference then
          resource = __add_resource(__method__, name, [], [], {}, {:"FOREIGN-REG" => nil})
          resource._ref_regs = regs
          return resource
        elsif regs == nil then
          resource = __add_resource(__method__, name, [], [], {}, {:"FOREIGN-REG" => nil})
          resource._ref_regs = nil
          return resource
        else
          fail "Error: invalid register"
        end
      end
      def _resolve_reference
        if @_ref_regs.class == Reference then
          regs = @_ref_regs.resolve
          fail "Error: can not found register Reference(#{@_ref_regs.args})" if regs.class != IRegister
          @_foreign_register_id = {:MODULE => regs._owner_module._id, :TABLE => regs._owner_table._id, :REGISTER => regs._id}
        end
      end
      define_method('<=') do |regs|
        state = @_owner_table._on_state
        fail "Error: not on state"           if state      == nil
        fail "Error: source is not register" if regs.class != IRegister
        state.__add_instruction(self, [], [], [regs], [])
        return self
      end
      define_method('=>') do |regs|
        state = @_owner_table._on_state
        fail "Error: not on state"           if state      == nil
        fail "Error: source is not register" if regs.class != IRegister
        state.__add_instruction(self, [], [], [], [regs])
        return self
      end
    end

    class Assert
      SINGLETON  = true
      STATE_PROC = Proc.new { |*regs| 
        resource = @_owner_table.__add_resource(:Assert, nil, [], [], {}, {})
        return __add_instruction(resource, [], [], regs , [])
      }
    end

    class Print 
      SINGLETON  = true
      STATE_PROC = Proc.new { |*regs| 
        resource = @_owner_table.__add_resource(:Print, nil, [], [], {}, {})
        return __add_instruction(resource, [], [], regs , [])
      }
    end

    class ChannelRead
      RESOURCE_PROC     = Proc.new { |name, type| __add_resource(__method__, name, [type], [type], {}, {}) }
      define_method('<=') do |channel_read|
        @_owner_design.__add_channel(self, channel_read)
        return self
      end
      define_method('=>') do |regs|
        state = @_owner_table._on_state
        fail "Error: not on state"           if state      == nil
        fail "Error: source is not register" if regs.class != IRegister
        state.__add_instruction(self, [], [], [], [regs])
        return self
      end
    end

    class ChannelWrite
      RESOURCE_PROC     = Proc.new { |name, type| __add_resource(__method__, name, [type], [type], {}, {}) }
      define_method('<=') do |regs|
        state = @_owner_table._on_state
        fail "Error: not on state"           if state      == nil
        fail "Error: source is not register" if regs.class != IRegister
        state.__add_instruction(self, [], [], [regs], [])
        return self
      end
    end
    
    class Embedded    
      PARAMS        = {:NAME => nil, :FILE => nil, :CLOCK => nil, :RESET => nil, :ARGS => nil, :REQ => nil, :ACK => nil}
      RESOURCE_PROC = Proc.new do |name, input_types, output_types, args|
        params = Hash.new
        args.each_pair do |key, value|
          fail "Error: undefined embedded parameter #{key}" if PARAMS.key?(key) == false
          if key == :NAME then
            params["EMBEDDED-MODULE"] = value
          else
            params["EMBEDDED-MODULE-" + key.to_s] = value
          end
        end
        __add_resource(__method__, name, input_types, output_types, params, {})
      end
      define_method('<=') do |regs|
        state = @_owner_table._on_state
        fail "Error: not on state"           if state      == nil
        fail "Error: source is not register" if regs.class != IRegister
        state.__add_instruction(self, [], [], [regs], [])
        return self
      end
      define_method('=>') do |regs|
        state = @_owner_table._on_state
        fail "Error: not on state"           if state      == nil
        fail "Error: source is not register" if regs.class != IRegister
        state.__add_instruction(self, [], [], [], [regs])
        return self
      end
    end

    class SubModuleTask
      RESOURCE_PROC = Proc.new { |name| __add_resource(__method__, name, [], [], {}, {}) }
      def entry
        state = @_owner_table._on_state
        fail "Error: not on state" if state == nil
        state.__add_instruction(self, [], [], [], [])
      end
    end

    class SubModuleTaskCall
      attr_accessor :_ref_task
      RESOURCE_PROC = Proc.new do  |name, task|
        if    task.class == SubModuleTask then
          resource = __add_resource(__method__, name, [], [], {}, {:'CALLEE-TABLE' => {:MODULE => task._owner_module._id, :TABLE => task._owner_table._id}})
          resource._ref_task = nil
          return resource
        elsif task.class == Reference then
          resource = __add_resource(__method__, name, [], [], {}, {:'CALLEE-TABLE' => nil})
          resource._ref_task = task
          return resource
        elsif task == nil then
          resource = __add_resource(__method__, name, [], [], {}, {:'CALLEE-TABLE' => nil})
          resource._ref_task = nil
          return resource
        else
          fail "Error: invalid task"
        end
      end
      def _resolve_reference
        if @_ref_task.class == Reference then
          task  = @_ref_task.resolve
          fail "Error: can not found task Reference(#{@_ref_task.args})" if task == nil
          callee(task)
        end
      end
      def callee(task)
        if task.class == SubModuleTask then
          @_callee_table_id = {:MODULE => task._owner_module._id, :TABLE => task._owner_table._id}
        else
          fail "Error: invalid task"
        end
      end
      def call
        state = @_owner_table._on_state
        fail "Error: not on state" if state == nil
        state.__add_instruction(self, [], [], [], [])
      end
    end

    class SiblingTask
      RESOURCE_PROC = Proc.new { |name,type| __add_resource(__method__, name, [type], [], {}, {}) }
      def entry(regs)
        state = @_owner_table._on_state
        fail "Error: not on state"           if state      == nil
        fail "Error: source is not register" if regs.class != IRegister
        state.__add_instruction(self, [], [], [], [regs])
        return self
      end
    end
    
    class SiblingTaskCall
      attr_accessor :_ref_task
      RESOURCE_PROC = Proc.new do  |name, type, task|
        if    task.class == SiblingTask then
          resource = __add_resource(__method__, name, [type], [], {}, {:'CALLEE-TABLE' => {:MODULE => task._owner_module._id, :TABLE => task._owner_table._id}})
          resource._ref_task = nil
          return resource
        elsif task.class == Reference then
          resource = __add_resource(__method__, name, [type], [], {}, {:'CALLEE-TABLE' => nil})
          resource._ref_task = task
          return resource
        elsif task == nil then
          resource = __add_resource(__method__, name, [type], [], {}, {:'CALLEE-TABLE' => nil})
          resource._ref_task = nil
          return resource
        else
          fail "Error: invalid task"
        end
      end
      def _resolve_reference
        if @_ref_task.class == Reference then
          task  = @ref_task.resolve
          fail "Error: can not found task Reference(#{@ref_task.args})" if task == nil
          callee(task)
        end
      end
      def callee(task)
        if task.class == SiblingTask then
          @_callee_table_id = {:MODULE => task._owner_module._id, :TABLE => task._owner_table._id}
        else
          fail "Error: invalid task"
        end
      end
      def call(regs)
        state = @_owner_table._on_state
        fail "Error: not on state"           if state      == nil
        fail "Error: source is not register" if regs.class != IRegister
        state.__add_instruction(self, [], [], [regs], [])
      end
      def wait
        state = @_owner_table._on_state
        fail "Error: not on state"           if state      == nil
        state.__add_instruction(self, [:wait], [], [], [])
      end
    end
    
    class Transition
      SINGLETON = true
    end

  end

  RESOURSE_CLASSES = ObjectSpace.each_object(Class).select{|klass| klass.to_s =~ /Iroha::Builder::Simple::IResource::*/}

  RESOURSE_CLASSES.each do |klass|
    resource_class_name = klass.to_s.split(/::/).last.to_sym
    if klass.const_defined?(:BINARY_OPERATOR) then
      binary_operator = klass.const_get(:BINARY_OPERATOR)
      IRegister.send(:define_method,
                     binary_operator,
                     Proc.new { |value|
                       opr1_regs = IRegister.clone(self )
                       opr2_regs = IRegister.clone(value)
                       return Operator.new(resource_class_name, [opr1_regs, opr2_regs])
                     })
    end
    if klass.const_defined?(:RESOURCE_PROC) then
      ITable.send(:define_method, resource_class_name, klass.const_get(:RESOURCE_PROC))
    end
    if klass.const_defined?(:STATE_PROC   ) then
      IState.send(:define_method, resource_class_name, klass.const_get(:STATE_PROC   ))
    end
  end
end
