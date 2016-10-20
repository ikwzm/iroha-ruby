module Iroha::Builder::Simple::Resource

  class Add
    BINARY_OPERATOR   = '+'
    INSTANCE_OPERATOR = true
    OPERATOR_NAME     = :Add
    TABLE_PROC = Proc.new{define_method(OPERATOR_NAME) do |name, i_types, o_types| __add_resource(OPERATOR_NAME, name, i_types, o_types, {}, {}) end}
    STATE_PROC = Proc.new{define_method(OPERATOR_NAME) do |*regs| Operator.new(@_owner_table, OPERATOR_NAME, regs) end}
    def _complement_output_types(input_registers)
      super(input_registers)
      input_0_min = @_input_types[0]._min
      input_0_max = @_input_types[0]._max
      input_1_min = @_input_types[1]._min
      input_1_max = @_input_types[1]._max
      @_output_types[0] = Iroha::Builder::Simple::Type.generate_numeric_type(
        input_0_min + input_1_min,
        input_0_min + input_1_max,
        input_0_max + input_1_min,
        input_0_max + input_1_max
      )
    end
  end
    
  class Sub
    BINARY_OPERATOR   = '-'
    INSTANCE_OPERATOR = true
    OPERATOR_NAME     = :Sub
    TABLE_PROC = Proc.new{define_method(OPERATOR_NAME) do |name, i_types, o_types| __add_resource(OPERATOR_NAME, name, i_types, o_types, {}, {}) end}
    STATE_PROC = Proc.new{define_method(OPERATOR_NAME) do |*regs| Operator.new(@_owner_table, OPERATOR_NAME, regs) end}
    def _complement_output_types(input_registers)
      super(input_registers)
      input_0_min = @_input_types[0]._min
      input_0_max = @_input_types[0]._max
      input_1_min = @_input_types[1]._min
      input_1_max = @_input_types[1]._max
      @_output_types[0] = Iroha::Builder::Simple::Type.generate_numeric_type(
        input_0_min - input_1_min,
        input_0_min - input_1_max,
        input_0_max - input_1_min,
        input_0_max - input_1_max
      )
    end
  end
    
  class Mul
    BINARY_OPERATOR   = '*'
    INSTANCE_OPERATOR = true
    OPERATOR_NAME     = :Mul
    TABLE_PROC = Proc.new{define_method(OPERATOR_NAME) do |name, i_types, o_types| __add_resource(OPERATOR_NAME, name, i_types, o_types, {}, {}) end}
    STATE_PROC = Proc.new{define_method(OPERATOR_NAME) do |*regs| Operator.new(@_owner_table, OPERATOR_NAME, regs) end}
    def _complement_output_types(input_registers)
      super(input_registers)
      input_0_min = @_input_types[0]._min
      input_0_max = @_input_types[0]._max
      input_1_min = @_input_types[1]._min
      input_1_max = @_input_types[1]._max
      @_output_types[0] = Iroha::Builder::Simple::Type.generate_numeric_type(
        input_0_min * input_1_min,
        input_0_min * input_1_max,
        input_0_max * input_1_min,
        input_0_max * input_1_max
      )
    end
  end
      
  class Gt 
    BINARY_OPERATOR   = '>'
    INSTANCE_OPERATOR = true
    OPERATOR_NAME     = :Gt
    TABLE_PROC = Proc.new{define_method(OPERATOR_NAME) do |name, i_types, o_types| __add_resource(OPERATOR_NAME, name, i_types, o_types, {}, {}) end}
    STATE_PROC = Proc.new{define_method(OPERATOR_NAME) do |*regs| Operator.new(@_owner_table, OPERATOR_NAME, regs) end}
    def _complement_output_types(input_registers)
      super(input_registers)
      @_output_types[0] = Iroha::Builder::Simple::Type::Unsigned.new(0)
    end
  end

  class Gte
    BINARY_OPERATOR   = '>='
    INSTANCE_OPERATOR = true
    OPERATOR_NAME     = :Gte
    TABLE_PROC = Proc.new{define_method(OPERATOR_NAME) do |name, i_types, o_types| __add_resource(OPERATOR_NAME, name, i_types, o_types, {}, {}) end}
    STATE_PROC = Proc.new{define_method(OPERATOR_NAME) do |*regs| Operator.new(@_owner_table, OPERATOR_NAME, regs) end}
    def _complement_output_types(input_registers)
      super(input_registers)
      @_output_types[0] = Iroha::Builder::Simple::Type::Unsigned.new(0)
    end
  end

  class Eq 
    BINARY_OPERATOR   = '=='
    INSTANCE_OPERATOR = true
    OPERATOR_NAME     = :Eq
    TABLE_PROC = Proc.new{define_method(OPERATOR_NAME) do |name, i_types, o_types| __add_resource(OPERATOR_NAME, name, i_types, o_types, {}, {}) end}
    STATE_PROC = Proc.new{define_method(OPERATOR_NAME) do |*regs| Operator.new(@_owner_table, OPERATOR_NAME, regs) end}
    def _complement_output_types(input_registers)
      super(input_registers)
      @_output_types[0] = Iroha::Builder::Simple::Type::Unsigned.new(0)
    end
  end

  class BitAnd
    BINARY_OPERATOR   = '&'
    INSTANCE_OPERATOR = true
    OPERATOR_NAME     = :BitAnd
    TABLE_PROC = Proc.new{define_method(OPERATOR_NAME) do |name, i_types, o_types| __add_resource(OPERATOR_NAME, name, i_types, o_types, {}, {}) end}
    STATE_PROC = Proc.new{define_method(OPERATOR_NAME) do |*regs| Operator.new(@_owner_table, OPERATOR_NAME, regs) end}
    def _complement_output_types(input_registers)
      super(input_registers)
      width = [@_input_types[0]._width, @_input_types[1]._width].max
      if @_input_types[0].kind_of?(Iroha::Type::Unsigned) and
         @_input_types[1].kind_of?(Iroha::Type::Unsigned) then
        @_output_types[0] = Iroha::Builder::Simple::Type::Unsigned.new(width)
      else
        @_output_types[0] = Iroha::Builder::Simple::Type::Signed  .new(width)
      end
    end
  end
    
  class BitOr 
    BINARY_OPERATOR   = '|'
    INSTANCE_OPERATOR = true
    OPERATOR_NAME     = :BitOr
    TABLE_PROC = Proc.new{define_method(OPERATOR_NAME) do |name, i_types, o_types| __add_resource(OPERATOR_NAME, name, i_types, o_types, {}, {}) end}
    STATE_PROC = Proc.new{define_method(OPERATOR_NAME) do |*regs| Operator.new(@_owner_table, OPERATOR_NAME, regs) end}
    def _complement_output_types(input_registers)
      super(input_registers)
      width = [@_input_types[0]._width, @_input_types[1]._width].max
      if @_input_types[0].kind_of?(Iroha::Type::Unsigned) and
         @_input_types[1].kind_of?(Iroha::Type::Unsigned) then
        @_output_types[0] = Iroha::Builder::Simple::Type::Unsigned.new(width)
      else
        @_output_types[0] = Iroha::Builder::Simple::Type::Signed  .new(width)
      end
    end
  end
    
  class BitXor
    BINARY_OPERATOR   = '^'
    INSTANCE_OPERATOR = true
    OPERATOR_NAME     = :BitXor
    TABLE_PROC = Proc.new{define_method(OPERATOR_NAME) do |name, i_types, o_types| __add_resource(OPERATOR_NAME, name, i_types, o_types, {}, {}) end}
    STATE_PROC = Proc.new{define_method(OPERATOR_NAME) do |*regs| Operator.new(@_owner_table, OPERATOR_NAME, regs) end}
    def _complement_output_types(input_registers)
      super(input_registers)
      width = [@_input_types[0]._width, @_input_types[1]._width].max
      if @_input_types[0].kind_of?(Iroha::Type::Unsigned) and
         @_input_types[1].kind_of?(Iroha::Type::Unsigned) then
        @_output_types[0] = Iroha::Builder::Simple::Type::Unsigned.new(width)
      else
        @_output_types[0] = Iroha::Builder::Simple::Type::Signed  .new(width)
      end
    end
  end
    
  class Shift 
    BINARY_OPERATOR   = '<<'
    INSTANCE_OPERATOR = true
    OPERATOR_NAME     = :Shift
    TABLE_PROC = Proc.new{define_method(OPERATOR_NAME) do |name, i_types, o_types| __add_resource(OPERATOR_NAME, name, i_types, o_types, {}, {}) end}
    STATE_PROC = Proc.new{define_method(OPERATOR_NAME) do |*regs| Operator.new(@_owner_table, OPERATOR_NAME, regs) end}
    def _complement_output_types(input_registers)
      super(input_registers)
      if input_registers[1]._class == :CONST and
         input_registers[1]._value.kind_of?(Integer) then
        width = @_input_types[0]._width + input_registers[1]._value
        @_output_types[0] = @_input_types[0].class.new(width)
      else 
        @_output_types[0] = @_input_types[0].clone
      end
    end
  end
      
  class BitInv
    UNARY_OPERATOR    = '~'
    INSTANCE_OPERATOR = true
    OPERATOR_NAME     = :BitInv
    TABLE_PROC = Proc.new{define_method(OPERATOR_NAME) do |name, i_types, o_types| __add_resource(OPERATOR_NAME, name, i_types, o_types, {}, {}) end}
    STATE_PROC = Proc.new{define_method(OPERATOR_NAME) do |*regs| Operator.new(@_owner_table, OPERATOR_NAME, regs) end}
    def _complement_output_types(input_registers)
      super(input_registers)
      @_output_types[0] = @_input_types[0].clone
    end
  end

  class BitSel 
    INSTANCE_OPERATOR = true
    OPERATOR_NAME     = :BitSel
    TABLE_PROC = Proc.new{define_method(OPERATOR_NAME) do |name, i_types, o_types| __add_resource(OPERATOR_NAME, name, i_types, o_types, {}, {}) end}
    STATE_PROC = Proc.new{define_method(OPERATOR_NAME) do |*regs| Operator.new(@_owner_table, OPERATOR_NAME, regs) end}
    def _complement_output_types(input_registers)
      super(input_registers)
      if input_registers[1]._class == :CONST and
         input_registers[1]._value.kind_of?(Integer) and
         input_registers[2]._class == :CONST and
         input_registers[2]._value.kind_of?(Integer) then
        msb   = input_registers[1]._value
        lsb   = input_registers[2]._value
        width = msb - lsb + 1
        @_output_types[0] = @_input_types[0].class.new(width)
      end
    end
  end

  class BitConcat
    INSTANCE_OPERATOR = true
    OPERATOR_NAME     = :BitConcat
    TABLE_PROC = Proc.new{define_method(OPERATOR_NAME) do |name, i_types, o_types| __add_resource(OPERATOR_NAME, name, i_types, o_types, {}, {}) end}
    STATE_PROC = Proc.new{define_method(OPERATOR_NAME) do |*regs| Operator.new(@_owner_table, OPERATOR_NAME, regs) end}
    def _complement_output_types(input_registers)
      super(input_registers)
      width = @_input_types.inject(0){|total_width, input_type_width| total_width = total_width + input_type_width}
      @_output_types[0] = @_input_types[0].class.new(width)
    end
  end
    
  class Select
    INSTANCE_OPERATOR = true
    OPERATOR_NAME     = :Select
    TABLE_PROC = Proc.new{define_method(OPERATOR_NAME) do |name, i_types, o_types| __add_resource(OPERATOR_NAME, name, i_types, o_types, {}, {}) end}
    STATE_PROC = Proc.new{define_method(OPERATOR_NAME) do |*regs| Operator.new(@_owner_table, OPERATOR_NAME, regs) end}
    def _complement_output_types(input_registers)
      super(input_registers)
      @_output_types[0] = @_input_types[1].clone
    end
  end

  class Set
    def _complement_output_types(input_registers)
      super(input_registers)
      if (@_input_types.size == 1) then
        @_output_types[0] = @_input_types[0].clone
      end
    end
  end

  class Transition
    SINGLETON = true
  end

end
