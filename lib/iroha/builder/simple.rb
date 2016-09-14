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
      @module_last_id  = 1
      @channel_last_id = 1
      if block_given? then
        self.instance_eval(&block)
      end
      resolve_reference()
      return self
    end

    def resolve_reference
      @modules.each_pair{|id, mod| mod.resolve_reference}
    end

    def add_module(name, parent_id, &block)
      params       = Iroha::Builder::Simple::IResource::Params.new
      tables       = []
      module_class = self.class.const_set(name.capitalize, Class.new(Iroha::Builder::Simple::IModule))
      module_inst  = module_class.new(@module_last_id, name, parent_id, params, tables)
      @module_last_id = @module_last_id+1
      self.class.send(:define_method, module_inst.name, Proc.new do module_inst; end)
      super(module_inst)
      if block_given? then
        module_inst.instance_eval(&block)
      end
      return module_inst
    end

    def add_channel(channel_write, channel_read)
      channel = IChannel.new(@channel_last_id,
                             channel_write.input_types[0],
                             channel_write.owner_module.id,
                             channel_write.owner_table.id,
                             channel_write.id,
                             channel_read.owner_module.id,
                             channel_read.owner_table.id,
                             channel_read.id)
      @channel_last_id = @channel_last_id+1
      super(channel)
      return channel
    end

    def IModule(name, &block)
      return add_module(name, nil, &block)
    end

  end

  class IModule

    def initialize(id, name, parent_id, params, table_list)
      super
      @table_last_id = 1
    end

    def add_table(table)
      super
      self.class.send(:define_method, table.name, Proc.new do table; end)
    end

    def ITable(name, &block)
      table_class    = self.class.const_set(name.capitalize, Class.new(Iroha::Builder::Simple::ITable))
      table          = table_class.new(@table_last_id, name, [], [], [], nil)
      @table_last_id = @table_last_id+1
      add_table(table)
      if block_given? then
        table.instance_eval(&block)
      end
      return table
    end

    def IModule(name, &block)
      return @owner_design.add_module(name, @id, &block)
    end

    def resolve_reference
      @tables.each_pair{|id, table| table.resolve_reference}
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
    attr_reader   :init_state_id

    def initialize(id, name, resource_list, register_list, state_list, init_state_id)
      super(id, name, resource_list, register_list, state_list, init_state_id)
      @register_last_id = 1
      @resource_last_id = 1
      @state_last_id    = 1
      @insn_last_id     = 1
      @init_state_id    = nil
      @singleton_classes= Hash.new
      @state_class      = self.class.const_set(:State, Class.new(Iroha::Builder::Simple::IState))
      @on_state         = nil
    end

    def add_state(state)
      super
      self.class.send(  :define_method, state.name, Proc.new do state; end)
      @state_class.send(:define_method, state.name, Proc.new do state; end)
    end

    def IState(name, &block)
      state = @state_class.new(@state_last_id, name, [])
      @state_last_id = @state_last_id + 1
      if @init_state_id == nil
        @init_state_id = state.id
      end
      add_state(state)
      if block_given? then
        state_entry(state)
        state.instance_eval(&block)
        state_exit
      end
      return state
    end

    def Resource(class_name, name, input_types, output_types, params, option)
      return add_resource(class_name, name, input_types, output_types, params, option)
    end

    def Register(name, type)
      return add_register(name, :REG  , type)
    end
        
    def Constant(name, type)
      return add_register(name, :CONST, type)
    end

    def Wire(name, type)
      return add_register(name, :WIRE , type)
    end

    def Unsigned(width)
      return IValueType.new(false, width)
    end

    def Signed(width)
      return IValueType.new(true , width)
    end

    def Ref(*args)
      return Reference.new(@owner_design, args)
    end

    def state_entry(state)
      @on_state = state
    end

    def state_exit
      @on_state = nil
    end

    def on_state
      if @on_state.class == @state_class then
        return @on_state
      else
        return nil
      end
    end

    def resolve_reference()
      @resources.values.each do |resource|
        if resource.class.method_defined?(:resolve_reference) then
          resource.resolve_reference()
        end
      end
    end

    def add_register(name, klass, type)
      fail "Error: illegal type(#{type.class})" if type.class != IValueType
      register = IRegister.new(@register_last_id, name, klass, type, type.assign_value)
      @register_last_id = @register_last_id + 1
      super(register)
      if name.class == Symbol then
        self.class.send(  :define_method, name, Proc.new do register; end)
        @state_class.send(:define_method, name, Proc.new do register; end)
      end
      return register
    end

    def add_resource(class_name, name, input_types, output_types, params, option)
      res_params = IResource::Params.new
      res_params.update(params)
      resource_class = IResource.const_get(class_name)
      if resource_class.const_defined?(:SINGLETON) and @singleton_classes.key?(class_name) then
        resource = @singleton_classes[class_name]
      else
        resource = resource_class.new(@resource_last_id, input_types, output_types, res_params, option)
        @resource_last_id = @resource_last_id + 1
        super(resource)
      end
      if resource_class.const_defined?(:SINGLETON) then
        @singleton_classes[class_name] = resource
      end
      if name.class == Symbol then
        self.class.send(  :define_method, name, Proc.new do resource; end)
        if resource.class.const_defined?(:INSTANCE_OPERATOR) and resource.class.const_get(:INSTANCE_OPERATOR) then
          @state_class.send(:define_method, name, Proc.new{|*regs| Operator.new(resource, regs)})
        else
          @state_class.send(:define_method, name, Proc.new do resource; end)
        end
      end
      return resource
    end

    def add_instruction(resource, op_resources, next_states, input_registers, output_registers)
      insn = IInstruction.new(@insn_last_id,
                              resource.class_name,
                              resource.id,
                              op_resources,
                              next_states.map{    |state   | state.id},
                              input_registers.map{|register| register.id},
                              output_registers.map{|register| register.id})
      @insn_last_id = @insn_last_id + 1
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
      state = @owner_table.on_state
      fail "Error: not on state"           if state      == nil
      fail "Error: source is not register" if regs.class != IRegister
      resource = @owner_table.add_resource(:Set,  nil, [self.type] , [regs.type],{},{})
      insn     = state.add_instruction(resource,[],[], [self     ] , [regs     ]      )
      return self
    end

    define_method('<=') do |value|
      state = @owner_table.on_state
      if state != nil then
        if @klass == :CONST then
          fail "Error: Can not set data to Constant({#self.name}) on State(state.name)"
        end
        dst = IRegister.clone(self)
        if value.class.method_defined?(:'=>') then
          value.send(:'=>', dst)
          return dst
        elsif value.class == Operator then
          src       = value
          src_types = src.operand.map{|regs| regs.type}
          if src.op.class == Symbol then
            resource= @owner_table.add_resource(src.op,nil, src_types  , [dst.type],{},{})
            insn    = state.add_instruction(resource, [],[],src.operand, [dst     ]      )
          else
            resource= src.op
            insn    = state.add_instruction(resource, [],[],src.operand, [dst     ]      )
          end
        else
          fail "Error: illegal source value #{value.class}"
        end
        return dst
      else
        set_value(value)
        return self
      end
    end
  end

  class IState

    def add_instruction(resource, op_resources, next_states, input_registers, output_registers)
      ## p "add_instruction(#{resource}, op_resources, next_states, #{input_registers.map{|r|r.id}}, #{output_registers.map{|r|r.id}})"
      insn = @owner_table.add_instruction(resource, op_resources, next_states, input_registers, output_registers)
      super(insn)
      return insn
    end

    def insn(resource, op_resources, next_states, input_registers, output_registers)
      add_instruction(resource, op_resources, next_states, input_registers, output_registers)
    end

    def on( &block )
      if block_given? then
        @owner_table.state_entry(self)
        self.instance_eval(&block)
        @owner_table.state_exit
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
      resource = @owner_table.add_resource(:Transition, nil, [], [], {}, {})
      add_instruction(resource, [], next_state_list, [cond_regs], [])
    end

    def Goto(next_state)
      resource = @owner_table.add_resource(:Transition, nil, [], [], {}, {})
      add_instruction(resource, [], [next_state   ], [         ], [])
    end

    def To_Unsigned(value, width)
      type = IValueType.new(false, width)
      type.assign_value = value
      return @owner_table.add_register(nil, :CONST, type)
    end

    def To_Signed(value, width)
      type = IValueType.new(true , width)
      type.assign_value = value
      return @owner_table.add_register(nil, :CONST, type)
    end

  end

  class IValueType
    attr_accessor :assign_value
    def initialize(is_signed, width)
      super
      @assign_value = nil
    end

    define_method('<=') do |value|
      @assign_value = value
      return self
    end
    
  end

  class IResource

    def self.convert_from(resource)
      res_class = resource.class.to_s.split(/::/).last
      Iroha::Builder::Simple::IResource.const_get(res_class).convert_from(resource)
    end

    class ExtInput
      RESOURCE_PROC     = Proc.new{|name, width| add_resource(__method__, name, [], [], {INPUT:  name, WIDTH: width}, {})}
      define_method('=>') do |regs|
        state = @owner_table.on_state
        fail "Error: not on state"           if state      == nil
        fail "Error: source is not register" if regs.class != IRegister
        state.add_instruction(self, [], [], [], [regs])
        return self
      end
    end

    class ExtOutput
      RESOURCE_PROC     = Proc.new{|name, width| add_resource(__method__, name, [], [], {OUTPUT: name, WIDTH: width}, {})}
      define_method('<=') do |regs|
        state = @owner_table.on_state
        fail "Error: not on state"           if state      == nil
        fail "Error: source is not register" if regs.class != IRegister
        state.add_instruction(self, [], [], [regs], [])
        return self
      end
    end

    class Add
      BINARY_OPERATOR   = '+'
      INSTANCE_OPERATOR = true
      STATE_PROC        = Proc.new{|*regs| Operator.new(__method__, regs)}
      RESOURCE_PROC     = Proc.new{|name, i_types, o_types| add_resource(__method__, name, i_types, o_types, {}, {})}
    end
    
    class Sub
      BINARY_OPERATOR   = '-'
      INSTANCE_OPERATOR = true
      STATE_PROC        = Proc.new{|*regs| Operator.new(__method__, regs)}
      RESOURCE_PROC     = Proc.new{|name, i_types, o_types| add_resource(__method__, name, i_types, o_types, {}, {})}
    end
    
    class Mul
      BINARY_OPERATOR   = '*'
      INSTANCE_OPERATOR = true
      STATE_PROC        = Proc.new{|*regs| Operator.new(__method__, regs)}
      RESOURCE_PROC     = Proc.new{|name, i_types, o_types| add_resource(__method__, name, i_types, o_types, {}, {})}
    end
      
    class Gt 
      BINARY_OPERATOR   = '>'
      INSTANCE_OPERATOR = true
      STATE_PROC        = Proc.new{|*regs| Operator.new(__method__, regs)}
      RESOURCE_PROC     = Proc.new{|name, i_types, o_types| add_resource(__method__, name, i_types, o_types, {}, {})}
    end

    class Gte
      BINARY_OPERATOR   = '>='
      INSTANCE_OPERATOR = true
      STATE_PROC        = Proc.new{|*regs| Operator.new(__method__, regs)}
      RESOURCE_PROC     = Proc.new{|name, i_types, o_types| add_resource(__method__, name, i_types, o_types, {}, {})}
    end

    class Eq 
      BINARY_OPERATOR   = '=='
      INSTANCE_OPERATOR = true
      STATE_PROC        = Proc.new{|*regs| Operator.new(__method__, regs)}
      RESOURCE_PROC     = Proc.new{|name, i_types, o_types| add_resource(__method__, name, i_types, o_types, {}, {})}
    end

    class BitAnd
      BINARY_OPERATOR   = '&'
      INSTANCE_OPERATOR = true
      STATE_PROC        = Proc.new{|*regs| Operator.new(__method__, regs)}
      RESOURCE_PROC     = Proc.new{|name, i_types, o_types| add_resource(__method__, name, i_types, o_types, {}, {})}
    end
    
    class BitOr 
      BINARY_OPERATOR   = '|'
      INSTANCE_OPERATOR = true
      STATE_PROC        = Proc.new{|*regs| Operator.new(__method__, regs)}
      RESOURCE_PROC     = Proc.new{|name, i_types, o_types| add_resource(__method__, name, i_types, o_types, {}, {})}
    end
    
    class BitXor
      BINARY_OPERATOR   = '^'
      INSTANCE_OPERATOR = true
      STATE_PROC        = Proc.new{|*regs| Operator.new(__method__, regs)}
      RESOURCE_PROC     = Proc.new{|name, i_types, o_types| add_resource(__method__, name, i_types, o_types, {}, {})}
    end
    
    class Shift 
      BINARY_OPERATOR   = '<<'
      INSTANCE_OPERATOR = true
      STATE_PROC        = Proc.new{|*regs| Operator.new(__method__, regs)}
      RESOURCE_PROC     = Proc.new{|name, i_types, o_types| add_resource(__method__, name, i_types, o_types, {}, {})}
    end
      
    class BitInv
      INSTANCE_OPERATOR = true
      STATE_PROC        = Proc.new{|*regs| Operator.new(__method__, regs)}
      RESOURCE_PROC     = Proc.new{|name, i_types, o_types| add_resource(__method__, name, i_types, o_types, {}, {})}
    end

    class BitSel 
      INSTANCE_OPERATOR = true
      STATE_PROC        = Proc.new{|*regs| Operator.new(__method__, regs)}
      RESOURCE_PROC     = Proc.new{|name, i_types, o_types| add_resource(__method__, name, i_types, o_types, {}, {})}
    end

    class BitConcat
      INSTANCE_OPERATOR = true
      STATE_PROC        = Proc.new{|*regs| Operator.new(__method__, regs)}
      RESOURCE_PROC     = Proc.new{|name, i_types, o_types| add_resource(__method__, name, i_types, o_types, {}, {})}
    end
    
    class Array    
      RESOURCE_PROC     = Proc.new{|name, addr_width, value_type, ownership, mem_type|
        fail "Error Illegal ownership #{ownership} of Array" if (ownership != :EXTERNAL and ownership != :INTERNAL)
        fail "Error Illegal mem type  #{mem_type}  of Array" if (mem_type  != :RAM      and mem_type  != :ROM     )
        is_external = (ownership == :EXTERNAL)
	is_ram      = (mem_type  == :RAM     )
        add_resource(__method__, name, [], [], {}, {ARRAY: {ADDR_WIDTH: addr_width, VALUE_TYPE: value_type, EXTERNAL: is_external, RAM: is_ram}})
      }
      class Data
        attr_reader :array, :addr
        def initialize(array, addr)
          @array = array
          @addr  = addr
        end
        define_method('<=') do |regs|
          state = @array.owner_table.on_state
          fail "Error: not on state"           if state      == nil
          fail "Error: source is not register" if regs.class != IRegister
          state.add_instruction(@array, [], [], [@addr,regs],[])
        end
        define_method('=>') do |regs|
          state = @array.owner_table.on_state
          fail "Error: not on state"           if state      == nil
          fail "Error: source is not register" if regs.class != IRegister
          state.add_instruction(@array, [], [], [@addr], [regs])
          return self
        end
      end
      define_method('[]') do |addr|
        fail "Error: address is not register" if addr.class != IRegister
        return Data.new(self, addr)
      end
    end

    class ForeignReg
      attr_accessor :ref_regs
      RESOURCE_PROC = Proc.new do |name, regs|
        if    regs.class == IRegister then
          resource = add_resource(__method__, name, [], [], {}, Hash({:"FOREIGN-REG" => {:MODULE => regs.owner_module.id, :TABLE => regs.owner_table.id, :REGISTER => regs.id}}))
          resource.ref_regs = nil
          return resource
        elsif regs.class == Reference then
          resource = add_resource(__method__, name, [], [], {}, {:"FOREIGN-REG" => nil})
          resource.ref_regs = regs
          return resource
        elsif regs == nil then
          resource = add_resource(__method__, name, [], [], {}, {:"FOREIGN-REG" => nil})
          resource.ref_regs = nil
          return resource
        else
          fail "Error: invalid register"
        end
      end
      def resolve_reference
        if @ref_regs.class == Reference then
          regs = @ref_regs.resolve
          fail "Error: can not found register Reference(#{@ref_regs.args})" if regs.class != IRegister
          self.option.update({:"FOREIGN-REG" => {:MODULE => regs.owner_module.id, :TABLE => regs.owner_table.id, :REGISTER => regs.id}})
        end
      end
      define_method('<=') do |regs|
        state = @owner_table.on_state
        fail "Error: not on state"           if state      == nil
        fail "Error: source is not register" if regs.class != IRegister
        state.add_instruction(self, [], [], [regs], [])
        return self
      end
      define_method('=>') do |regs|
        state = @owner_table.on_state
        fail "Error: not on state"           if state      == nil
        fail "Error: source is not register" if regs.class != IRegister
        state.add_instruction(self, [], [], [], [regs])
        return self
      end
    end

    class Assert
      SINGLETON  = true
      STATE_PROC = Proc.new { |*regs| 
        resource = @owner_table.add_resource(:Assert, nil, [], [], {}, {})
        return add_instruction(resource, [], [], regs , [])
      }
    end

    class Print 
      SINGLETON  = true
      STATE_PROC = Proc.new { |*regs| 
        resource = @owner_table.add_resource(:Print, nil, [], [], {}, {})
        return add_instruction(resource, [], [], regs , [])
      }
    end

    class ChannelRead
      RESOURCE_PROC     = Proc.new { |name, type| add_resource(__method__, name, [type], [type], {}, {}) }
      define_method('<=') do |channel_read|
        @owner_design.add_channel(self, channel_read)
        return self
      end
      define_method('=>') do |regs|
        state = @owner_table.on_state
        fail "Error: not on state"           if state      == nil
        fail "Error: source is not register" if regs.class != IRegister
        state.add_instruction(self, [], [], [], [regs])
        return self
      end
    end

    class ChannelWrite
      RESOURCE_PROC     = Proc.new { |name, type| add_resource(__method__, name, [type], [type], {}, {}) }
      define_method('<=') do |regs|
        state = @owner_table.on_state
        fail "Error: not on state"           if state      == nil
        fail "Error: source is not register" if regs.class != IRegister
        state.add_instruction(self, [], [], [regs], [])
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
        add_resource(__method__, name, input_types, output_types, params, {})
      end
      define_method('<=') do |regs|
        state = @owner_table.on_state
        fail "Error: not on state"           if state      == nil
        fail "Error: source is not register" if regs.class != IRegister
        state.add_instruction(self, [], [], [regs], [])
        return self
      end
      define_method('=>') do |regs|
        state = @owner_table.on_state
        fail "Error: not on state"           if state      == nil
        fail "Error: source is not register" if regs.class != IRegister
        state.add_instruction(self, [], [], [], [regs])
        return self
      end
    end

    class SubModuleTask
      RESOURCE_PROC = Proc.new { |name| add_resource(__method__, name, [], [], {}, {}) }
      def entry
        state = @owner_table.on_state
        fail "Error: not on state" if state == nil
        state.add_instruction(self, [], [], [], [])
      end
    end

    class SubModuleTaskCall
      attr_accessor :ref_task
      RESOURCE_PROC = Proc.new do  |name, task|
        if    task.class == SubModuleTask then
          resource = add_resource(__method__, name, [], [], {}, {:'CALLEE-TABLE' => {:MODULE => task.owner_module.id, :TABLE => task.owner_table.id}})
          resource.ref_task = nil
          return resource
        elsif task.class == Reference then
          resource = add_resource(__method__, name, [], [], {}, {:'CALLEE-TABLE' => nil})
          resource.ref_task = task
          return resource
        elsif task == nil then
          resource = add_resource(__method__, name, [], [], {}, {:'CALLEE-TABLE' => nil})
          resource.ref_task = nil
          return resource
        else
          fail "Error: invalid task"
        end
      end
      def resolve_reference
        if @ref_task.class == Reference then
          task  = @ref_task.resolve
          fail "Error: can not found task Reference(#{@ref_task.args})" if task == nil
          callee(task)
        end
      end
      def callee(task)
        if task.class == SubModuleTask then
          self.option.update({:'CALLEE-TABLE' => {:MODULE => task.owner_module.id, :TABLE => task.owner_table.id}})
        else
          fail "Error: invalid task"
        end
      end
      def call
        state = @owner_table.on_state
        fail "Error: not on state" if state == nil
        state.add_instruction(self, [], [], [], [])
      end
    end

    class SiblingTask
      RESOURCE_PROC = Proc.new { |name,type| add_resource(__method__, name, [type], [], {}, {}) }
      def entry(regs)
        state = @owner_table.on_state
        fail "Error: not on state"           if state      == nil
        fail "Error: source is not register" if regs.class != IRegister
        state.add_instruction(self, [], [], [], [regs])
        return self
      end
    end
    
    class SiblingTaskCall
      attr_accessor :ref_task
      RESOURCE_PROC = Proc.new do  |name, type, task|
        if    task.class == SiblingTask then
          resource = add_resource(__method__, name, [type], [], {}, {:'CALLEE-TABLE' => {:MODULE => task.owner_module.id, :TABLE => task.owner_table.id}})
          resource.ref_task = nil
          return resource
        elsif task.class == Reference then
          resource = add_resource(__method__, name, [type], [], {}, {:'CALLEE-TABLE' => nil})
          resource.ref_task = task
          return resource
        elsif task == nil then
          resource = add_resource(__method__, name, [type], [], {}, {:'CALLEE-TABLE' => nil})
          resource.ref_task = nil
          return resource
        else
          fail "Error: invalid task"
        end
      end
      def resolve_reference
        if @ref_task.class == Reference then
          task  = @ref_task.resolve
          fail "Error: can not found task Reference(#{@ref_task.args})" if task == nil
          callee(task)
        end
      end
      def callee(task)
        if task.class == SiblingTask then
          self.option.update({:'CALLEE-TABLE' => {:MODULE => task.owner_module.id, :TABLE => task.owner_table.id}})
        else
          fail "Error: invalid task"
        end
      end
      def call(regs)
        state = @owner_table.on_state
        fail "Error: not on state"           if state      == nil
        fail "Error: source is not register" if regs.class != IRegister
        state.add_instruction(self, [], [], [regs], [])
      end
      def wait
        state = @owner_table.on_state
        fail "Error: not on state"           if state      == nil
        state.add_instruction(self, [:wait], [], [], [])
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
