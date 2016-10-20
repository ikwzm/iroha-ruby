module Iroha::Resource

  class Transition < Iroha::IResource
    CLASS_NAME   = "tr"
    IS_EXCLUSIVE = true
    def initialize(id, input_types, output_types, params, option)
      super(CLASS_NAME, IS_EXCLUSIVE, id, input_types, output_types, params, option)
    end
  end

  class Set        < Iroha::IResource
    CLASS_NAME   = "set"
    IS_EXCLUSIVE = false
    def initialize(id, input_types, output_types, params, option)
      super(CLASS_NAME, IS_EXCLUSIVE, id, input_types, output_types, params, option)
    end
    def _check_types
      return (super() and
              (@_input_types .size == 1 or @_input_types .size == 0) and
              (@_output_types.size == 1 or @_output_types.size == 0))
    end
    def _check_input_registers(input_registers)
      return false if (input_registers.class != Array)
      return false if (input_registers.size  != 1)
      return false if (input_registers[0].kind_of?(IRegister) == false)
      return false if (@_input_types.size == 1) and (@_input_types[0] != input_registers[0]._type)
      return true
    end
  end

  class Select     < Iroha::IResource
    CLASS_NAME   = "select"
    IS_EXCLUSIVE = false
    def initialize(id, input_types, output_types, params, option)
      super(CLASS_NAME, IS_EXCLUSIVE, id, input_types, output_types, params, option)
    end
    def _check_types
      return (super() and
              (@_input_types .size == 3) and
              (@_input_types[0].kind_of?(Iroha::Type::Unsigned) and
               @_input_types[0]._width == 0 or @_input_types[0]._width == 1) and
              (@_input_types[1] == @_input_types[2]) and
              (@_output_types.size == 1 or @_output_types.size == 0))
    end
  end

  class Gt         < Iroha::IResource
    CLASS_NAME   = "gt"
    IS_EXCLUSIVE = true
    def initialize(id, input_types, output_types, params, option)
      super(CLASS_NAME, IS_EXCLUSIVE, id, input_types, output_types, params, option)
    end
    def _check_types
      return (super() and
              (@_input_types .size == 2) and
              (@_input_types[0].kind_of?(Iroha::Type::Signed  ) or
               @_input_types[0].kind_of?(Iroha::Type::Unsigned)) and
              (@_input_types[1].kind_of?(Iroha::Type::Signed  ) or
               @_input_types[1].kind_of?(Iroha::Type::Unsigned)) and
              (@_output_types.size == 1 or @_output_types.size == 0))
    end
  end

  class Gte        < Iroha::IResource
    CLASS_NAME   = "gte"
    IS_EXCLUSIVE = true
    def initialize(id, input_types, output_types, params, option)
      super(CLASS_NAME, IS_EXCLUSIVE, id, input_types, output_types, params, option)
    end
    def _check_types
      return (super() and
              (@_input_types .size == 2) and
              (@_input_types[0].kind_of?(Iroha::Type::Signed  ) or
               @_input_types[0].kind_of?(Iroha::Type::Unsigned)) and
              (@_input_types[1].kind_of?(Iroha::Type::Signed  ) or
               @_input_types[1].kind_of?(Iroha::Type::Unsigned)) and
              (@_output_types.size == 1 or @_output_types.size == 0))
    end
  end

  class Eq         < Iroha::IResource
    CLASS_NAME   = "eq"
    IS_EXCLUSIVE = true
    def initialize(id, input_types, output_types, params, option)
      super(CLASS_NAME, IS_EXCLUSIVE, id, input_types, output_types, params, option)
    end
    def _check_types
      return (super() and
              (@_input_types .size == 2) and
              (@_input_types[0].kind_of?(Iroha::Type::Signed  ) or
               @_input_types[0].kind_of?(Iroha::Type::Unsigned)) and
              (@_input_types[1].kind_of?(Iroha::Type::Signed  ) or
               @_input_types[1].kind_of?(Iroha::Type::Unsigned)) and
              (@_output_types.size == 1 or @_output_types.size == 0))
    end
  end

  class Add        < Iroha::IResource
    CLASS_NAME   = "add"
    IS_EXCLUSIVE = true
    def initialize(id, input_types, output_types, params, option)
      super(CLASS_NAME, IS_EXCLUSIVE, id, input_types, output_types, params, option)
    end
    def _check_types
      return (super() and
              (@_input_types .size == 2) and
              (@_input_types[0].kind_of?(Iroha::Type::Signed  ) or
               @_input_types[0].kind_of?(Iroha::Type::Unsigned)) and
              (@_input_types[1].kind_of?(Iroha::Type::Signed  ) or
               @_input_types[1].kind_of?(Iroha::Type::Unsigned)) and
              (@_output_types.size == 1 or @_output_types.size == 0))
    end
  end

  class Sub        < Iroha::IResource
    CLASS_NAME   = "sub"
    IS_EXCLUSIVE = true
    def initialize(id, input_types, output_types, params, option)
      super(CLASS_NAME, IS_EXCLUSIVE, id, input_types, output_types, params, option)
    end
    def _check_types
      return (super() and
              (@_input_types .size == 2) and
              (@_input_types[0].kind_of?(Iroha::Type::Signed  ) or
               @_input_types[0].kind_of?(Iroha::Type::Unsigned)) and
              (@_input_types[1].kind_of?(Iroha::Type::Signed  ) or
               @_input_types[1].kind_of?(Iroha::Type::Unsigned)) and
              (@_output_types.size == 1 or @_output_types.size == 0))
    end
  end

  class Mul        < Iroha::IResource
    CLASS_NAME   = "mul"
    IS_EXCLUSIVE = true
    def initialize(id, input_types, output_types, params, option)
      super(CLASS_NAME, IS_EXCLUSIVE, id, input_types, output_types, params, option)
    end
    def _check_types
      return (super() and
              (@_input_types .size == 2) and
              (@_input_types[0].kind_of?(Iroha::Type::Signed  ) or
               @_input_types[0].kind_of?(Iroha::Type::Unsigned)) and
              (@_input_types[1].kind_of?(Iroha::Type::Signed  ) or
               @_input_types[1].kind_of?(Iroha::Type::Unsigned)) and
              (@_output_types.size == 1 or @_output_types.size == 0))
    end
  end

  class BitAnd     < Iroha::IResource
    CLASS_NAME   = "bit-and"
    IS_EXCLUSIVE = false
    def initialize(id, input_types, output_types, params, option)
      super(CLASS_NAME, IS_EXCLUSIVE, id, input_types, output_types, params, option)
    end
    def _check_types
      return (super() and
              (@_input_types .size == 2) and
              (@_input_types[0].kind_of?(Iroha::Type::Signed  ) or
               @_input_types[0].kind_of?(Iroha::Type::Unsigned)) and
              (@_input_types[1].kind_of?(Iroha::Type::Signed  ) or
               @_input_types[1].kind_of?(Iroha::Type::Unsigned)) and
              (@_output_types.size == 1 or @_output_types.size == 0))
    end
  end

  class BitOr      < Iroha::IResource
    CLASS_NAME   = "bit-or"
    IS_EXCLUSIVE = false
    def initialize(id, input_types, output_types, params, option)
      super(CLASS_NAME, IS_EXCLUSIVE, id, input_types, output_types, params, option)
    end
    def _check_types
      return (super() and
              (@_input_types .size == 2) and
              (@_input_types[0].kind_of?(Iroha::Type::Signed  ) or
               @_input_types[0].kind_of?(Iroha::Type::Unsigned)) and
              (@_input_types[1].kind_of?(Iroha::Type::Signed  ) or
               @_input_types[1].kind_of?(Iroha::Type::Unsigned)) and
              (@_output_types.size == 1 or @_output_types.size == 0))
    end
  end

  class BitXor     < Iroha::IResource
    CLASS_NAME   = "bit-xor"
    IS_EXCLUSIVE = false
    def initialize(id, input_types, output_types, params, option)
      super(CLASS_NAME, IS_EXCLUSIVE, id, input_types, output_types, params, option)
    end
    def _check_types
      return (super() and
              (@_input_types .size == 2) and
              (@_input_types[0].kind_of?(Iroha::Type::Signed  ) or
               @_input_types[0].kind_of?(Iroha::Type::Unsigned)) and
              (@_input_types[1].kind_of?(Iroha::Type::Signed  ) or
               @_input_types[1].kind_of?(Iroha::Type::Unsigned)) and
              (@_output_types.size == 1 or @_output_types.size == 0))
    end
  end

  class BitInv     < Iroha::IResource
    CLASS_NAME   = "bit-inv"
    IS_EXCLUSIVE = false
    def initialize(id, input_types, output_types, params, option)
      super(CLASS_NAME, IS_EXCLUSIVE, id, input_types, output_types, params, option)
    end
    def _check_types
      return (super() and
              (@_input_types .size == 1) and
              (@_input_types[0].kind_of?(Iroha::Type::Signed  ) or
               @_input_types[0].kind_of?(Iroha::Type::Unsigned)) and
              (@_output_types.size == 1 or @_output_types.size == 0))
    end
  end

  class Shift      < Iroha::IResource
    CLASS_NAME   = "shift"
    IS_EXCLUSIVE = false
    def initialize(id, input_types, output_types, params, option)
      super(CLASS_NAME, IS_EXCLUSIVE, id, input_types, output_types, params, option)
    end
    def _check_types
      return (super() and
              (@_input_types .size == 2) and
              (@_input_types[0].kind_of?(Iroha::Type::Signed  ) or
               @_input_types[0].kind_of?(Iroha::Type::Unsigned)) and
              (@_input_types[1].kind_of?(Iroha::Type::Signed  ) or
               @_input_types[1].kind_of?(Iroha::Type::Unsigned)) and
              (@_output_types.size == 1 or @_output_types.size == 0))
    end
  end

  class BitSel     < Iroha::IResource
    CLASS_NAME   = "bit-sel"
    IS_EXCLUSIVE = false
    def initialize(id, input_types, output_types, params, option)
      super(CLASS_NAME, IS_EXCLUSIVE, id, input_types, output_types, params, option)
    end
    def _check_input_registers(input_registers)
      return false if super(input_registers) == false
      return false if (input_registers[1]._class != :CONST)
      return false if (input_registers[1]._value.kind_of?(Integer) == false)
      return false if (input_registers[2]._class != :CONST)
      return false if (input_registers[2]._value.kind_of?(Integer) == false)
      return true
    end
    def _check_types
      return (super() and
              (@_input_types .size == 3) and
              (@_input_types[0].kind_of?(Iroha::Type::Signed  ) or
               @_input_types[0].kind_of?(Iroha::Type::Unsigned)) and
              (@_input_types[1].kind_of?(Iroha::Type::Signed  ) or
               @_input_types[1].kind_of?(Iroha::Type::Unsigned)) and
              (@_input_types[2].kind_of?(Iroha::Type::Signed  ) or
               @_input_types[2].kind_of?(Iroha::Type::Unsigned)) and
              (@_output_types.size == 1 or @_output_types.size == 0))
    end
  end

  class BitConcat  < Iroha::IResource
    CLASS_NAME   = "bit-concat"
    IS_EXCLUSIVE = false
    def initialize(id, input_types, output_types, params, option)
      super(CLASS_NAME, IS_EXCLUSIVE, id, input_types, output_types, params, option)
    end
    def _check_types
      return (super() and
              (@_input_types .size >= 1) and
              (@_output_types.size == 1 or @_output_types.size == 0))
    end
  end

  class Mapped     < Iroha::IResource
    CLASS_NAME   = "mapped"
    IS_EXCLUSIVE = true
    def initialize(id, input_types, output_types, params, option)
      super(CLASS_NAME, IS_EXCLUSIVE, id, input_types, output_types, params, option)
    end
  end

  class Phi        < Iroha::IResource
    CLASS_NAME   = "phi"
    IS_EXCLUSIVE = false
    def initialize(id, input_types, output_types, params, option)
      super(CLASS_NAME, IS_EXCLUSIVE, id, input_types, output_types, params, option)
    end
  end

end
