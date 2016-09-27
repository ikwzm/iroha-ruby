module Iroha::Builder::Simple::Resource

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

  class Transition
    SINGLETON = true
  end

end
