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
      table_class = self.class.const_set(name.capitalize, Class.new(Iroha::Builder::Simple::ITable))
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

    def IState(name, &block)
      state = _add_new_state(@_state_class, name, [])
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
      type = Type::Numeric.new(false, width)
      type._assign_value = nil
      return type
    end

    def Signed(width)
      type = Type::Numeric.new(true , width)
      type._assign_value = nil
      return type
    end

    def StateType(table)
      type = Type::State.new(table._owner_module._id, table._id)
      type._assign_value = nil
      return type
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
      fail "Error: illegal type(#{type.class})" if type.kind_of?(Iroha::IType) == false
      register = _add_new_register(IRegister, name, klass, type, type._assign_value)
      if name.class == Symbol then
        self.class.send(   :define_method, name, Proc.new do register; end)
        @_state_class.send(:define_method, name, Proc.new do register; end)
      end
      return register
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
        self.class.send(  :define_method, name, Proc.new do resource; end)
        if resource.class.const_defined?(:INSTANCE_OPERATOR) and resource.class.const_get(:INSTANCE_OPERATOR) then
          @_state_class.send(:define_method, name, Proc.new{|*regs| Operator.new(resource, regs)})
        else
          @_state_class.send(:define_method, name, Proc.new do resource; end)
        end
      end
      return resource
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
      fail "Error: not on state"           if state.nil?
      fail "Error: source is not register" if regs.class != IRegister
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
      type = Type::Numeric.new(false, width)
      type._assign_value = value
      return @_owner_table.__add_register(nil, :CONST, type)
    end

    def To_Signed(value, width)
      type = Type::Numeric.new(true , width)
      type._assign_value = value
      return @_owner_table.__add_register(nil, :CONST, type)
    end

  end

  module ITypeModule
    attr_accessor :_assign_value
    define_method('<=') do |value|
      @_assign_value = value
      return self
    end
  end

  TYPE_CLASSES = Iroha::Builder::Simple::Type.constants.map{|c| Iroha::Builder::Simple::Type.const_get(c)}

  TYPE_CLASSES.each do |type_class|
    type_class.include(Iroha::Builder::Simple::ITypeModule)
  end

  Iroha::RESOURCE_PATH_LIST.each do |path|
    require_relative "../#{path}/builder/simple.rb"
  end

  RESOURSE_CLASSES = Iroha::Builder::Simple::Resource.constants.map{|c| Iroha::Builder::Simple::Resource.const_get(c)}

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
