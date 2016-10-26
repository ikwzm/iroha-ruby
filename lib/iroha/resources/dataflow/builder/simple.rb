module Iroha::Builder::Simple::Resource

  class DataFlowIn

    TABLE_PROC = Proc.new {
      def DataFlowIn(**args)
        fail "Error: #{__method__} illegal argument size" if args.size != 1
        name, type = args.shift
        __add_resource(:DataFlowIn, name, [type], [], {}, {})
      end
    }

    define_method('<=') do |regs|
      state = @_owner_table._on_state
      fail "Error: not on state"           if state.nil?
      fail "Error: source is not register" if regs.class != Iroha::Builder::Simple::IRegister
      state.__add_instruction(self, [], [], [regs], [])
      return self
    end
    
  end

end
