require_relative '../iroha'
require_relative '../iroha/modules/addable'

module Iroha
  module Builder
    module Simple
      Iroha.franchise_class(self, Iroha)
      Iroha.include_module( self, Iroha::Modules::Addable)
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
      _add_new_initialize
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
      module_inst  = _add_new_module(module_class, name, parent_id, params, tables)
      self.class.send(:define_method, module_inst._name, Proc.new do module_inst; end)
      if block_given? then
        module_inst.instance_eval(&block)
      end
      return module_inst
    end

    def __add_channel(channel_write, channel_read)
      return _add_new_channel(IChannel, 
                              channel_write._input_types[0],
                              channel_write._owner_module._id,
                              channel_write._owner_table._id,
                              channel_write._id,
                              channel_read._owner_module._id,
                              channel_read._owner_table._id,
                              channel_read._id)
    end

    def IModule(name, &block)
      return __add_module(name, nil, &block)
    end

  end

  class IModule

    def initialize(id, name, parent_id, params, table_list)
      super
      _add_new_initialize()
    end

    def ITable(name, &block)
      table_class = self.class.const_set(name.capitalize, Class.new(Iroha::Builder::Simple::IStepTable))
      table       = _add_new_table(table_class, name, [], [], [], nil)
      self.class.send(:define_method, table._name, Proc.new do table; end)
      if block_given? then
        table.instance_eval(&block)
      end
      return table
    end

    def IFlow(name, &block)
      table_class = self.class.const_set(name.capitalize, Class.new(Iroha::Builder::Simple::IFlowTable))
      table       = _add_new_table(table_class, name, [], [], [], nil)
      self.class.send(:define_method, table._name, Proc.new do table; end)
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

    def initialize(id, name, resource_list, register_list, state_list, init_state_id)
      super(id, name, resource_list, register_list, state_list, init_state_id)
      _add_new_initialize()
      @_singleton_classes = Hash.new
      @_state_class       = self.class.const_set(:State, Class.new(Iroha::Builder::Simple::IState))
      @_on_state          = nil
    end

    def Resource(class_name, name, input_types, output_types, params, option)
      return __add_resource(class_name, name, input_types, output_types, params, option)
    end

    def Register(**args)
      return args.to_a.map do |arg|
        __add_table_register(arg[0], :REG , arg[1])
      end
    end

    def Constant(**args)
      return args.to_a.map do |arg|
        __add_table_register(arg[0], :CONST, arg[1])
      end
    end

    def Wire(**args)
      return args.to_a.map do |arg|
        __add_table_register(arg[0], :WIRE , arg[1])
      end
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
      if @_on_state.kind_of?(@_state_class) then
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

    def __add_table_register(name, klass, type)
      register = __add_register(name, klass , type)
      if name.class == Symbol then
        self   .class.send(:define_method, name, Proc.new do register; end)
        @_state_class.send(:define_method, name, Proc.new do register; end)
      end
      return register
    end

    def __add_register(name, klass, type)
      if type.class == Array then
        name_index_width = Math::log10(type.size).ceil
        name_format      = (name_index_width > 0) ? "%s_%0#{name_index_width}d" : "%s"
        registers = Array.new
        type.each_with_index do |type, index|
          fail "Error: illegal type(#{type.class})" if type.kind_of?(Iroha::IType) == false
          register_name = sprintf(name_format, name, index).to_sym
          registers[index] = _add_new_register(IRegister, register_name, klass, type, type._assign_value)
        end
        return registers
      else
        fail "Error: illegal type(#{type.class})" if type.kind_of?(Iroha::IType) == false
        return _add_new_register(IRegister, name, klass, type, type._assign_value)
      end
    end

    def __add_resource(class_name, name, input_types, output_types, params, option)
      res_params = IParams.new
      res_params.update(params)
      resource_class = Resource.const_get(class_name)
      if resource_class.const_defined?(:SINGLETON) and @_singleton_classes.key?(class_name) then
        resource = @_singleton_classes[class_name]
      else
        resource = _add_new_resource(resource_class, input_types, output_types, res_params, option)
      end
      if resource_class.const_defined?(:SINGLETON) then
        @_singleton_classes[class_name] = resource
      end
      if name.class == Symbol then
        self.class.send(:define_method, name, Proc.new do resource; end)
        if resource.class.const_defined?(:INSTANCE_OPERATOR) and resource.class.const_get(:INSTANCE_OPERATOR) then
          @_state_class.send(:define_method, name, Proc.new{|*regs| Operator.new(self._owner_table, resource, regs)})
        else
          @_state_class.send(:define_method, name, Proc.new do resource; end)
        end
      end
      return resource
    end

  end

  class IStepTable < ITable

    def IState(name, &block)
      state = _add_new_state(Class.new(@_state_class), name, [])
      if @_init_state_id == nil
        @_init_state_id = state._id
      end
      self   .class.send(:define_method, state._name, Proc.new do state; end)
      @_state_class.send(:define_method, state._name, Proc.new do state; end)
      if block_given? then
        _state_entry(state)
        state.instance_eval(&block)
        _state_exit
      end
      return state
    end

  end

  class IFlowTable < ITable

    def initialize(id, name, resource_list, register_list, state_list, init_state_id)
      super(id, name, resource_list, register_list, state_list, init_state_id)
      @dataflow_in_type     = Type::Unsigned.new(1)
      @dataflow_in_register = nil
      @dataflow_in_resource = _add_new_resource(Resource::DataFlowIn, [@dataflow_in_type], [], IParams.new, nil)
    end

    def IStage(*stage_names)
      stage_list = stage_names.map do |stage_name|
        _add_new_state(Class.new(@_state_class), stage_name, [])
      end
      stage_list.each do |stage|
        self   .class.send(:define_method, stage._name, Proc.new do stage; end)
        @_state_class.send(:define_method, stage._name, Proc.new do stage; end)
        if @_init_state_id == nil
          @_init_state_id = stage._id
          if @dataflow_in_register.nil? == false then
            stage.__add_instruction(@dataflow_in_resource, [], [], [@dataflow_in_register], [])
          end
        end
        stage
      end
      stage_list.slice(0,stage_list.size-1).each_index do |i|
        stage_list[i].Goto(stage_list[i+1])
      end
      return stage_list
    end

    def Start(name)
      @dataflow_in_register = __add_table_register(name, :WIRE , @dataflow_in_type)
      return @dataflow_in_register
    end
  end


  class Operator
    attr_reader :_owner_table, :_resource, :_operand

    def initialize(table, resource, operand)
      @_owner_table = table
      @_resource    = resource
      @_operand     = operand
    end

    def generate_register
      state = @_owner_table._on_state
      fail "Error: not on state" if state.nil?
      input_registers = @_operand.map{|operand| operand.generate_register}
      if @_resource.class == Symbol then
        input_types = input_registers.map{|register| register._type}
        @_resource  = @_owner_table.__add_resource(@_resource ,nil, input_types, [], {}, {})
        @_resource._complement_output_types(input_registers)
      end
      output_types     = @_resource._output_types
      output_registers = output_types.map{|type| @_owner_table.__add_register(nil, :WIRE, type)}
      if output_registers.size != 1 then
        fail "Error: illegal output_types in generate_register(#{@_resource._class_name},#{output_types})"
      end
      insn = state.__add_instruction(@_resource, [], [], input_registers, output_registers)
      return output_registers[0]
    end

    define_method('=>') do |regs|
      state = @_owner_table._on_state
      fail "Error: not on state" if state.nil?
      input_registers = @_operand.map{|operand| operand.generate_register}
      if @_resource.class == Symbol then
        input_types = input_registers.map{|register| register._type}
        @_resource  = @_owner_table.__add_resource(@_resource ,nil, input_types, [regs._type], {}, {})
      end
      insn = state.__add_instruction(@_resource, [], [], input_registers, [regs])
      return self
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

    def generate_register
      return IRegister.convert_from(self)
    end

    define_method('=>') do |regs|
      state = @_owner_table._on_state
      fail "Error: not on state"                if state.nil?
      fail "Error: distination is not register" if regs.class != IRegister
      resource = @_owner_table.__add_resource(:Set, nil, [self._type] , [regs._type],{},{})
      insn     = state.__add_instruction(resource,[],[], [self      ] , [regs      ]      )
      return self
    end

    define_method('<=') do |value|
      state = @_owner_table._on_state
      if state.nil? == false then
        if @_class == :CONST then
          fail "Error: Can not set data to Constant({#self._name}) on State(state._name)"
        end
        dst = IRegister.clone(self)
        if value.class.method_defined?(:'=>') then
          value.send(:'=>', dst)
          return dst
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
      return _add_new_instruction(
        IInstruction,
        resource._class_name,
        resource._id,
        op_resources,
        next_states     .map{|state   | state._id   },
        input_registers .map{|register| register._id},
        output_registers.map{|register| register._id}
      )
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

    def __add_local_register(name, klass, type)
      register_name = (@_name.nil?) ? "state_{#@_id}_#{name}" : "#{@_name}_#{name}"
      register = @_owner_table.__add_register(register_name, klass, type)
      if name.class == Symbol then
        self.class.send(:define_method, name, Proc.new do register; end)
      end
      return register
    end

    def Register(**args)
      return args.to_a.map do |arg|
        __add_local_register(arg[0], :REG , arg[1])
      end
    end

    def Constant(**args)
      return args.to_a.map do |arg|
        __add_local_register(arg[0], :CONST, arg[1])
      end
    end

    def Wire(**args)
      return args.to_a.map do |arg|
        __add_local_register(arg[0], :WIRE , arg[1])
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

  end

  Iroha::TYPE_PATH_LIST.each do |path|
    require_relative "../#{path}/builder/simple.rb"
  end

  TYPE_CLASSES = Iroha::Builder::Simple::Type.constants.map{|c| Iroha::Builder::Simple::Type.const_get(c)}

  TYPE_CLASSES.each do |klass|
    if klass.const_defined?(:TABLE_PROC) then
      ITable.class_eval(&klass.const_get(:TABLE_PROC))
    end
    if klass.const_defined?(:STATE_PROC) then
      IState.class_eval(&klass.const_get(:STATE_PROC))
    end
  end

  Iroha::RESOURCE_PATH_LIST.each do |path|
    require_relative "../#{path}/builder/simple.rb"
  end

  RESOURSE_CLASSES = Iroha::Builder::Simple::Resource.constants.map{|c| Iroha::Builder::Simple::Resource.const_get(c)}

  RESOURSE_CLASSES.each do |klass|
    if klass.const_defined?(:OPERATOR_PROC) then
      IRegister.class_eval(&klass.const_get(:OPERATOR_PROC))
      Operator .class_eval(&klass.const_get(:OPERATOR_PROC))
    end
    if klass.const_defined?(:TABLE_PROC) then
      ITable.class_eval(&klass.const_get(:TABLE_PROC))
    end
    if klass.const_defined?(:STATE_PROC) then
      IState.class_eval(&klass.const_get(:STATE_PROC))
    end
  end
end
