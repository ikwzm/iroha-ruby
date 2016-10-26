module Iroha::Builder::Simple::Resource

  class Add
    INSTANCE_OPERATOR = true
    TABLE_PROC        = Proc.new{define_method(:Add) { |name, i_types, o_types| __add_resource(:Add, name, i_types, o_types, {}, {}) } }
    STATE_PROC        = Proc.new{define_method(:Add) { |*regs| Operator.new(@_owner_table, :Add, regs) } }
    OPERATOR_PROC     = Proc.new{define_method('+')  { |value| Operator.new(@_owner_table, :Add, [self, value]) } }
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
    INSTANCE_OPERATOR = true
    TABLE_PROC        = Proc.new{define_method(:Sub) { |name, i_types, o_types| __add_resource(:Sub, name, i_types, o_types, {}, {}) } }
    STATE_PROC        = Proc.new{define_method(:Sub) { |*regs| Operator.new(@_owner_table, :Sub, regs) } }
    OPERATOR_PROC     = Proc.new{define_method('-')  { |value| Operator.new(@_owner_table, :Sub, [self, value]) } }
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
    INSTANCE_OPERATOR = true
    TABLE_PROC        = Proc.new{define_method(:Mul) { |name, i_types, o_types| __add_resource(:Mul, name, i_types, o_types, {}, {}) } }
    STATE_PROC        = Proc.new{define_method(:Mul) { |*regs| Operator.new(@_owner_table, :Mul, regs) } }
    OPERATOR_PROC     = Proc.new{define_method('*')  { |value| Operator.new(@_owner_table, :Mul, [self, value]) } }
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
    INSTANCE_OPERATOR = true
    TABLE_PROC        = Proc.new{define_method(:Gt) { |name, i_types, o_types| __add_resource(:Gt, name, i_types, o_types, {}, {}) } }
    STATE_PROC        = Proc.new{define_method(:Gt) { |*regs| Operator.new(@_owner_table, :Gt, regs) } }
    OPERATOR_PROC     = Proc.new{define_method('>') { |value| Operator.new(@_owner_table, :Gt, [self, value]) }
                                 define_method('<') { |value| Operator.new(@_owner_table, :Gt, [value, self]) }}
    def _complement_output_types(input_registers)
      super(input_registers)
      @_output_types[0] = Iroha::Builder::Simple::Type::Unsigned.new(0)
    end
  end

  class Gte
    INSTANCE_OPERATOR = true
    TABLE_PROC        = Proc.new{define_method(:Gte) { |name, i_types, o_types| __add_resource(:Gte, name, i_types, o_types, {}, {}) } }
    STATE_PROC        = Proc.new{define_method(:Gte) { |*regs| Operator.new(@_owner_table, :Gte, regs) } }
    OPERATOR_PROC     = Proc.new{define_method('>=') { |value| Operator.new(@_owner_table, :Gte, [self, value]) } }
    def _complement_output_types(input_registers)
      super(input_registers)
      @_output_types[0] = Iroha::Builder::Simple::Type::Unsigned.new(0)
    end
  end

  class Eq 
    INSTANCE_OPERATOR = true
    TABLE_PROC        = Proc.new{define_method(:Eq ) { |name, i_types, o_types| __add_resource(:Eq, name, i_types, o_types, {}, {}) } }
    STATE_PROC        = Proc.new{define_method(:Eq ) { |*regs| Operator.new(@_owner_table, :Eq, regs) } }
    OPERATOR_PROC     = Proc.new{define_method('==') { |value| Operator.new(@_owner_table, :Eq, [self, value]) }
                                 define_method('!=') { |value| Operator.new(@_owner_table, :BitInv, [
                                                               Operator.new(@_owner_table, :Eq, [self, value])]) } }
    def _complement_output_types(input_registers)
      super(input_registers)
      @_output_types[0] = Iroha::Builder::Simple::Type::Unsigned.new(0)
    end
  end

  class BitAnd
    INSTANCE_OPERATOR = true
    TABLE_PROC        = Proc.new{define_method(:BitAnd) { |name, i_types, o_types| __add_resource(:BitAnd, name, i_types, o_types, {}, {}) } }
    STATE_PROC        = Proc.new{define_method(:BitAnd) { |*regs| Operator.new(@_owner_table, :BitAnd, regs) } }
    OPERATOR_PROC     = Proc.new{define_method('&')     { |value| Operator.new(@_owner_table, :BitAnd, [self, value]) } }
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
    INSTANCE_OPERATOR = true
    TABLE_PROC        = Proc.new{define_method(:BitOr) { |name, i_types, o_types| __add_resource(:BitOr, name, i_types, o_types, {}, {}) } }
    STATE_PROC        = Proc.new{define_method(:BitOr) { |*regs| Operator.new(@_owner_table, :BitOr, regs) } }
    OPERATOR_PROC     = Proc.new{define_method('|')    { |value| Operator.new(@_owner_table, :BitOr, [self, value]) } }
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
    INSTANCE_OPERATOR = true
    TABLE_PROC        = Proc.new{define_method(:BitXor) { |name, i_types, o_types| __add_resource(:BitXor, name, i_types, o_types, {}, {}) } }
    STATE_PROC        = Proc.new{define_method(:BitXor) { |*regs| Operator.new(@_owner_table, :BitXor, regs) } }
    OPERATOR_PROC     = Proc.new{define_method('^')     { |value| Operator.new(@_owner_table, :BitXor, [self, value]) } }
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
    INSTANCE_OPERATOR = true
    TABLE_PROC        = Proc.new{define_method(:Shift) { |name, i_types, o_types| __add_resource(:Shift, name, i_types, o_types, {}, {}) } }
    STATE_PROC        = Proc.new{define_method(:Shift) { |*regs| Operator.new(@_owner_table, :Shift, regs) } }
    OPERATOR_PROC     = Proc.new{define_method('<<')   { |value| Operator.new(@_owner_table, :Shift, [self, value]) }
                                 define_method('>>')   { |value| Operator.new(@_owner_table, :Shift, [self,
                                                                 Operator.new(@_owner_table, :Sub  , [To_Unsigned(0,32), value])]) } }
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
    INSTANCE_OPERATOR = true
    TABLE_PROC        = Proc.new{define_method(:BitInv) { |name, i_types, o_types| __add_resource(:BitInv, name, i_types, o_types, {}, {}) } }
    STATE_PROC        = Proc.new{define_method(:BitInv) { |*regs| Operator.new(@_owner_table, :BitInv, regs) } }
    OPERATOR_PROC     = Proc.new{define_method('~')     {         Operator.new(@_owner_table, :BitInv, [self]) }
                                 define_method('!')     {         Operator.new(@_owner_table, :BitInv, [self]) } }
    def _complement_output_types(input_registers)
      super(input_registers)
      @_output_types[0] = @_input_types[0].clone
    end
  end

  class BitSel 
    INSTANCE_OPERATOR = true
    TABLE_PROC        = Proc.new{define_method(:BitSel) { |name, i_types, o_types| __add_resource(:BitSel, name, i_types, o_types, {}, {}) } }
    STATE_PROC        = Proc.new{define_method(:BitSel) { |*args|
                                   regs    = []
                                   regs[0] = args[0]
                                   width   = 32
                                   if    args.size == 2 then
                                     if args[1].kind_of?(Integer) then
                                       regs[1] = To_Unsigned(args[1], width)
                                       regs[2] = regs[1]
                                     else
                                       regs[1] = args[1]
                                       regs[2] = args[1]
                                     end
                                   elsif args.size >= 3 then
                                     if args[1].kind_of?(Integer) then
                                       regs[1] = To_Unsigned(args[1], width)
                                     else
                                       regs[1] = args[1]
                                     end
                                     if args[2].kind_of?(Integer) then
                                       regs[2] = To_Unsigned(args[2], width)
                                     else
                                       regs[2] = args[2]
                                     end
                                   end
                                   Operator.new(@_owner_table, :BitSel, regs)
                                }}
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
    TABLE_PROC        = Proc.new{define_method(:BitConcat) { |name, i_types, o_types| __add_resource(:BitConcat, name, i_types, o_types, {}, {}) } }
    STATE_PROC        = Proc.new{define_method(:BitConcat) { |*regs| Operator.new(@_owner_table, :BitConcat, regs) } }
    def _complement_output_types(input_registers)
      super(input_registers)
      width = @_input_types.inject(0){|total_width, input_type| total_width = total_width + input_type._width}
      @_output_types[0] = @_input_types[0].class.new(width)
    end
  end
    
  class Select
    INSTANCE_OPERATOR = true
    TABLE_PROC        = Proc.new{define_method(:Select) { |name, i_types, o_types| __add_resource(:Select, name, i_types, o_types, {}, {}) } }
    STATE_PROC        = Proc.new{define_method(:Select) { |*regs| Operator.new(@_owner_table, :Select, regs) } }
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
