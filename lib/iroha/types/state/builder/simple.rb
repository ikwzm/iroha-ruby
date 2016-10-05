module Iroha::Builder::Simple::Type

  class State
    attr_accessor :_assign_value

    define_method('<=') do |value|
      @_assign_value = value
      return self
    end

    TABLE_PROC = Proc.new{
      def StateType(table)
        type = Type::State.new(table._owner_module._id, table._id)
        type._assign_value = nil
        return type
      end
    }
  end
  
end
