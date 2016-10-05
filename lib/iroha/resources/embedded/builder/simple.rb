module Iroha::Builder::Simple::Resource
  
  class Embedded    
    PARAMS = {:NAME => nil, :FILE => nil, :CLOCK => nil, :RESET => nil, :ARGS => nil, :REQ => nil, :ACK => nil}

    TABLE_PROC = Proc.new {
      def Embedded(name, input_types, output_types, args)
        params = Hash.new
        args.each_pair do |key, value|
          fail "Error: undefined embedded parameter #{key}" if PARAMS.key?(key) == false
          if key == :NAME then
            params["EMBEDDED-MODULE"] = value
          else
            params["EMBEDDED-MODULE-" + key.to_s] = value
          end
        end
        __add_resource(:Embedded, name, input_types, output_types, params, {})
      end
    }
    
    define_method('<=') do |regs|
      state = @_owner_table._on_state
      fail "Error: not on state"           if state.nil?
      fail "Error: source is not register" if regs.class != Iroha::Builder::Simple::IRegister
      state.__add_instruction(self, [], [], [regs], [])
      return self
    end

    define_method('=>') do |regs|
      state = @_owner_table._on_state
      fail "Error: not on state"           if state.nil?
      fail "Error: source is not register" if regs.class != Iroha::Builder::Simple::IRegister
      state.__add_instruction(self, [], [], [], [regs])
      return self
    end
  end

end

