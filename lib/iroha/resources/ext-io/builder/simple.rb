module Iroha::Builder::Simple::Resource

  class ExtInput

    TABLE_PROC = Proc.new{
      def ExtInput(**args)
        return args.to_a.map do |arg|
          __add_resource(:ExtInput, arg[0], [], [], {INPUT:  arg[0], WIDTH: arg[1]}, {})
        end
      end
    }
    
    define_method('=>') do |regs|
      state = @_owner_table._on_state
      fail "Error: not on state"           if state.nil?
      fail "Error: source is not register" if regs.class != Iroha::Builder::Simple::IRegister
      state.__add_instruction(self, [], [], [], [regs])
      return self
    end
  end

  class ExtOutput

    TABLE_PROC = Proc.new{
      def ExtOutput(**args)
        return args.to_a.map do |arg|
          __add_resource(:ExtOutput, arg[0], [], [], {OUTPUT: arg[0], WIDTH: arg[1]}, {})
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
