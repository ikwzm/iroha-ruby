class Iroha::Builder::Simple::IResource

  class Array    
    RESOURCE_PROC     = Proc.new{|name, addr_width, value_type, ownership, mem_type|
      fail "Error Illegal ownership #{ownership} of Array" if (ownership != :EXTERNAL and ownership != :INTERNAL)
      fail "Error Illegal mem type  #{mem_type}  of Array" if (mem_type  != :RAM      and mem_type  != :ROM     )
      __add_resource(__method__, name, [], [], {}, {ARRAY: [addr_width, value_type, ownership, mem_type]})
    }
    class Data
      attr_reader :array, :addr
      def initialize(array, addr)
        @array = array
        @addr  = addr
      end
      define_method('<=') do |regs|
        state = @array._owner_table._on_state
        fail "Error: not on state"           if state.nil?
        fail "Error: source is not register" if regs.class != Iroha::Builder::Simple::IRegister
        state.__add_instruction(@array, [], [], [@addr,regs],[])
      end
      define_method('=>') do |regs|
        state = @array._owner_table._on_state
        fail "Error: not on state"           if state.nil?
        fail "Error: source is not register" if regs.class != Iroha::Builder::Simple::IRegister
        state.__add_instruction(@array, [], [], [@addr], [regs])
        return self
      end
    end
    define_method('[]') do |addr|
      fail "Error: address is not register"  if addr.class != Iroha::Builder::Simple::IRegister
      return Data.new(self, addr)
    end
  end

end

