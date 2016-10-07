module Iroha::Builder::Simple::Type

  class Signed
    attr_accessor :_assign_value

    define_method('<=') do |value|
      @_assign_value = value
      return self
    end

    TABLE_PROC = Proc.new{
      def Signed(width)
        type = Type::Signed.new(width)
        type._assign_value = nil
        return type
      end
    }

    STATE_PROC = Proc.new{
      def Signed(width)
        type = Type::Signed.new(width)
        type._assign_value = nil
        return type
      end
      def To_Signed(value, width)
        type = Type::Signed.new(width)
        type._assign_value = value
        return @_owner_table.__add_register(nil, :CONST, type)
      end
    }
  end
  
  class Unsigned
    attr_accessor :_assign_value

    define_method('<=') do |value|
      @_assign_value = value
      return self
    end

    TABLE_PROC = Proc.new{
      def Unsigned(width)
        type = Type::Unsigned.new(width)
        type._assign_value = nil
        return type
      end
    }

    STATE_PROC = Proc.new{
      def Unsigned(width)
        type = Type::Unsigned.new(width)
        type._assign_value = nil
        return type
      end
      def To_Unsigned(value, width)
        type = Type::Unsigned.new(width)
        type._assign_value = value
        return @_owner_table.__add_register(nil, :CONST, type)
      end
    }
  end
end

