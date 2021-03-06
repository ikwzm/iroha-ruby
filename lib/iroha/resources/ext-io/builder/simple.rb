module Iroha::Builder::Simple::Resource

  class ExtInput

    TABLE_PROC = Proc.new{
      def ExtInput(**args)
        fail "Error: #{__method__} illegal argument size" if args.size != 1
        name, type = args.shift
        __add_resource(:ExtInput, name, [], [], {INPUT:  name, WIDTH: type._width}, {})
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
        fail "Error: #{__method__} illegal argument size" if args.size != 1
        name, type = args.shift
        params = {:OUTPUT => name}
        if type._width.nil? == false then
          params[:WIDTH] = type._width
        end
        if type._assign_value.kind_of?(Integer) then
          params[:"DEFAULT-VALUE"] = type._assign_value
        end
        __add_resource(:ExtOutput, name, [], [], params, {})
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
