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
  end

  class Phi        < Iroha::IResource
    CLASS_NAME   = "phi"
    IS_EXCLUSIVE = false
    def initialize(id, input_types, output_types, params, option)
      super(CLASS_NAME, IS_EXCLUSIVE, id, input_types, output_types, params, option)
    end
  end

  class Select     < Iroha::IResource
    CLASS_NAME   = "select"
    IS_EXCLUSIVE = false
    def initialize(id, input_types, output_types, params, option)
      super(CLASS_NAME, IS_EXCLUSIVE, id, input_types, output_types, params, option)
    end
  end

  class Print      < Iroha::IResource
    CLASS_NAME   = "print"
    IS_EXCLUSIVE = false
    def initialize(id, input_types, output_types, params, option)
      super(CLASS_NAME, IS_EXCLUSIVE, id, input_types, output_types, params, option)
    end
  end

  class Assert     < Iroha::IResource
    CLASS_NAME   = "assert"
    IS_EXCLUSIVE = false
    def initialize(id, input_types, output_types, params, option)
      super(CLASS_NAME, IS_EXCLUSIVE, id, input_types, output_types, params, option)
    end
  end

  class Mapped     < Iroha::IResource
    CLASS_NAME   = "mapped"
    IS_EXCLUSIVE = true
    def initialize(id, input_types, output_types, params, option)
      super(CLASS_NAME, IS_EXCLUSIVE, id, input_types, output_types, params, option)
    end
  end

  class Gt         < Iroha::IResource
    CLASS_NAME   = "gt"
    IS_EXCLUSIVE = true
    def initialize(id, input_types, output_types, params, option)
      super(CLASS_NAME, IS_EXCLUSIVE, id, input_types, output_types, params, option)
    end
  end

  class Gte        < Iroha::IResource
    CLASS_NAME   = "gte"
    IS_EXCLUSIVE = true
    def initialize(id, input_types, output_types, params, option)
      super(CLASS_NAME, IS_EXCLUSIVE, id, input_types, output_types, params, option)
    end
  end

  class Eq         < Iroha::IResource
    CLASS_NAME   = "eq"
    IS_EXCLUSIVE = true
    def initialize(id, input_types, output_types, params, option)
      super(CLASS_NAME, IS_EXCLUSIVE, id, input_types, output_types, params, option)
    end
  end

  class Add        < Iroha::IResource
    CLASS_NAME   = "add"
    IS_EXCLUSIVE = true
    def initialize(id, input_types, output_types, params, option)
      super(CLASS_NAME, IS_EXCLUSIVE, id, input_types, output_types, params, option)
    end
  end

  class Sub        < Iroha::IResource
    CLASS_NAME   = "sub"
    IS_EXCLUSIVE = true
    def initialize(id, input_types, output_types, params, option)
      super(CLASS_NAME, IS_EXCLUSIVE, id, input_types, output_types, params, option)
    end
  end

  class Mul        < Iroha::IResource
    CLASS_NAME   = "mul"
    IS_EXCLUSIVE = true
    def initialize(id, input_types, output_types, params, option)
      super(CLASS_NAME, IS_EXCLUSIVE, id, input_types, output_types, params, option)
    end
  end

  class BitAnd     < Iroha::IResource
    CLASS_NAME   = "bit-and"
    IS_EXCLUSIVE = false
    def initialize(id, input_types, output_types, params, option)
      super(CLASS_NAME, IS_EXCLUSIVE, id, input_types, output_types, params, option)
    end
  end

  class BitOr      < Iroha::IResource
    CLASS_NAME   = "bit-or"
    IS_EXCLUSIVE = false
    def initialize(id, input_types, output_types, params, option)
      super(CLASS_NAME, IS_EXCLUSIVE, id, input_types, output_types, params, option)
    end
  end

  class BitXor     < Iroha::IResource
    CLASS_NAME   = "bit-xor"
    IS_EXCLUSIVE = false
    def initialize(id, input_types, output_types, params, option)
      super(CLASS_NAME, IS_EXCLUSIVE, id, input_types, output_types, params, option)
    end
  end

  class BitInv     < Iroha::IResource
    CLASS_NAME   = "bit-inv"
    IS_EXCLUSIVE = false
    def initialize(id, input_types, output_types, params, option)
      super(CLASS_NAME, IS_EXCLUSIVE, id, input_types, output_types, params, option)
    end
  end

  class Shift      < Iroha::IResource
    CLASS_NAME   = "shift"
    IS_EXCLUSIVE = false
    def initialize(id, input_types, output_types, params, option)
      super(CLASS_NAME, IS_EXCLUSIVE, id, input_types, output_types, params, option)
    end
  end

  class BitSel     < Iroha::IResource
    CLASS_NAME   = "bit-sel"
    IS_EXCLUSIVE = false
    def initialize(id, input_types, output_types, params, option)
      super(CLASS_NAME, IS_EXCLUSIVE, id, input_types, output_types, params, option)
    end
  end

  class BitConcat  < Iroha::IResource
    CLASS_NAME   = "bit-concat"
    IS_EXCLUSIVE = false
    def initialize(id, input_types, output_types, params, option)
      super(CLASS_NAME, IS_EXCLUSIVE, id, input_types, output_types, params, option)
    end
  end

end
