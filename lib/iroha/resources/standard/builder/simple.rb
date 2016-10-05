module Iroha::Builder::Simple::Resource

  class Add
    BINARY_OPERATOR   = '+'
    INSTANCE_OPERATOR = true
    OPERATOR_NAME     = :Add
    TABLE_PROC = Proc.new{define_method(OPERATOR_NAME) do |name, i_types, o_types| __add_resource(OPERATOR_NAME, name, i_types, o_types, {}, {}) end}
    STATE_PROC = Proc.new{define_method(OPERATOR_NAME) do |*regs| Operator.new(OPERATOR_NAME, regs) end}
  end
    
  class Sub
    BINARY_OPERATOR   = '-'
    INSTANCE_OPERATOR = true
    OPERATOR_NAME     = :Sub
    TABLE_PROC = Proc.new{define_method(OPERATOR_NAME) do |name, i_types, o_types| __add_resource(OPERATOR_NAME, name, i_types, o_types, {}, {}) end}
    STATE_PROC = Proc.new{define_method(OPERATOR_NAME) do |*regs| Operator.new(OPERATOR_NAME, regs) end}
  end
    
  class Mul
    BINARY_OPERATOR   = '*'
    INSTANCE_OPERATOR = true
    OPERATOR_NAME     = :Mul
    TABLE_PROC = Proc.new{define_method(OPERATOR_NAME) do |name, i_types, o_types| __add_resource(OPERATOR_NAME, name, i_types, o_types, {}, {}) end}
    STATE_PROC = Proc.new{define_method(OPERATOR_NAME) do |*regs| Operator.new(OPERATOR_NAME, regs) end}
  end
      
  class Gt 
    BINARY_OPERATOR   = '>'
    INSTANCE_OPERATOR = true
    OPERATOR_NAME     = :Gt
    TABLE_PROC = Proc.new{define_method(OPERATOR_NAME) do |name, i_types, o_types| __add_resource(OPERATOR_NAME, name, i_types, o_types, {}, {}) end}
    STATE_PROC = Proc.new{define_method(OPERATOR_NAME) do |*regs| Operator.new(OPERATOR_NAME, regs) end}
  end

  class Gte
    BINARY_OPERATOR   = '>='
    INSTANCE_OPERATOR = true
    OPERATOR_NAME     = :Gte
    TABLE_PROC = Proc.new{define_method(OPERATOR_NAME) do |name, i_types, o_types| __add_resource(OPERATOR_NAME, name, i_types, o_types, {}, {}) end}
    STATE_PROC = Proc.new{define_method(OPERATOR_NAME) do |*regs| Operator.new(OPERATOR_NAME, regs) end}
  end

  class Eq 
    BINARY_OPERATOR   = '=='
    INSTANCE_OPERATOR = true
    OPERATOR_NAME     = :Eq
    TABLE_PROC = Proc.new{define_method(OPERATOR_NAME) do |name, i_types, o_types| __add_resource(OPERATOR_NAME, name, i_types, o_types, {}, {}) end}
    STATE_PROC = Proc.new{define_method(OPERATOR_NAME) do |*regs| Operator.new(OPERATOR_NAME, regs) end}
  end

  class BitAnd
    BINARY_OPERATOR   = '&'
    INSTANCE_OPERATOR = true
    OPERATOR_NAME     = :BitAnd
    TABLE_PROC = Proc.new{define_method(OPERATOR_NAME) do |name, i_types, o_types| __add_resource(OPERATOR_NAME, name, i_types, o_types, {}, {}) end}
    STATE_PROC = Proc.new{define_method(OPERATOR_NAME) do |*regs| Operator.new(OPERATOR_NAME, regs) end}
  end
    
  class BitOr 
    BINARY_OPERATOR   = '|'
    INSTANCE_OPERATOR = true
    OPERATOR_NAME     = :BitOr
    TABLE_PROC = Proc.new{define_method(OPERATOR_NAME) do |name, i_types, o_types| __add_resource(OPERATOR_NAME, name, i_types, o_types, {}, {}) end}
    STATE_PROC = Proc.new{define_method(OPERATOR_NAME) do |*regs| Operator.new(OPERATOR_NAME, regs) end}
  end
    
  class BitXor
    BINARY_OPERATOR   = '^'
    INSTANCE_OPERATOR = true
    OPERATOR_NAME     = :BitXor
    TABLE_PROC = Proc.new{define_method(OPERATOR_NAME) do |name, i_types, o_types| __add_resource(OPERATOR_NAME, name, i_types, o_types, {}, {}) end}
    STATE_PROC = Proc.new{define_method(OPERATOR_NAME) do |*regs| Operator.new(OPERATOR_NAME, regs) end}
  end
    
  class Shift 
    BINARY_OPERATOR   = '<<'
    INSTANCE_OPERATOR = true
    OPERATOR_NAME     = :Shift
    TABLE_PROC = Proc.new{define_method(OPERATOR_NAME) do |name, i_types, o_types| __add_resource(OPERATOR_NAME, name, i_types, o_types, {}, {}) end}
    STATE_PROC = Proc.new{define_method(OPERATOR_NAME) do |*regs| Operator.new(OPERATOR_NAME, regs) end}
  end
      
  class BitInv
    INSTANCE_OPERATOR = true
    OPERATOR_NAME     = :BitInv
    TABLE_PROC = Proc.new{define_method(OPERATOR_NAME) do |name, i_types, o_types| __add_resource(OPERATOR_NAME, name, i_types, o_types, {}, {}) end}
    STATE_PROC = Proc.new{define_method(OPERATOR_NAME) do |*regs| Operator.new(OPERATOR_NAME, regs) end}
  end

  class BitSel 
    INSTANCE_OPERATOR = true
    OPERATOR_NAME     = :BitSel
    TABLE_PROC = Proc.new{define_method(OPERATOR_NAME) do |name, i_types, o_types| __add_resource(OPERATOR_NAME, name, i_types, o_types, {}, {}) end}
    STATE_PROC = Proc.new{define_method(OPERATOR_NAME) do |*regs| Operator.new(OPERATOR_NAME, regs) end}
  end

  class BitConcat
    INSTANCE_OPERATOR = true
    OPERATOR_NAME     = :BitConcat
    TABLE_PROC = Proc.new{define_method(OPERATOR_NAME) do |name, i_types, o_types| __add_resource(OPERATOR_NAME, name, i_types, o_types, {}, {}) end}
    STATE_PROC = Proc.new{define_method(OPERATOR_NAME) do |*regs| Operator.new(OPERATOR_NAME, regs) end}
  end
    
  class Transition
    SINGLETON = true
  end

end
