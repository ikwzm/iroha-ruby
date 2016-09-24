class Iroha::Builder::Simple::IResource
  
  class Embedded    
    PARAMS        = {:NAME => nil, :FILE => nil, :CLOCK => nil, :RESET => nil, :ARGS => nil, :REQ => nil, :ACK => nil}
    RESOURCE_PROC = Proc.new do |name, input_types, output_types, args|
      params = Hash.new
      args.each_pair do |key, value|
        fail "Error: undefined embedded parameter #{key}" if PARAMS.key?(key) == false
        if key == :NAME then
          params["EMBEDDED-MODULE"] = value
        else
          params["EMBEDDED-MODULE-" + key.to_s] = value
        end
      end
      __add_resource(__method__, name, input_types, output_types, params, {})
    end
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

