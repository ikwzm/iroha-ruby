module Iroha::Builder::Simple::Resource

  class DataFlowIn

    TABLE_PROC = Proc.new {
      def DataFlowIn(**args)
        return args.to_a.map do |arg|
          __add_resource(:DataFlowIn, arg[0], [arg[1]], [], {}, {})
        end
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
