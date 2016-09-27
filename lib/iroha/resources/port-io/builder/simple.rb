class Iroha::Builder::Simple::IResource

  class PortInput
    attr_accessor :_ref_resources
    RESOURCE_PROC = Proc.new do |name, type, *resources|
      params = {:INPUT => name, :WIDTH => type._width}
      resource = __add_resource(__method__, name, [], [type], params, {:"PORT-INPUT" => nil})
      resource._ref_resources = resources
      return resource
    end
    def _resolve_reference
      @_ref_resources.each do |ref|
        if ref.class == Iroha::Builder::Simple::Reference then
          resource = ref.resolve()
        else
          resource = ref
        end
        if resource.nil?  then
          fail "Error: can not found register Reference(#{ref.args})"
        end
        _add_connection(resource._owner_module._id, resource._owner_table._id, resource._id)
      end
    end
    define_method('=>') do |regs|
      state = @_owner_table._on_state
      fail "Error: not on state"           if state.nil?
      fail "Error: source is not register" if regs.class != Iroha::Builder::Simple::IRegister
      state.__add_instruction(self, [], [], [], [regs])
      return self
    end
    define_method('<=') do |regs|
      fail "Error: can not connect PortOut(#{_id_to_str}) to #{regs._id_to_str}" if regs.class != PortOutput
      self._add_connection(regs._owner_module._id, regs._owner_table._id, regs._id)
      regs._add_connection(self._owner_module._id, self._owner_table._id, self._id)
      return self
    end
  end

  class PortOutput
    attr_accessor :_ref_resources
    RESOURCE_PROC = Proc.new do |name, type, *resources| 
      params = {:OUTPUT => name, :WIDTH => type._width}
      resource = __add_resource(__method__, name, [type], [], params, nil)
      resource._ref_resources = resources
      return resource
    end
    def _resolve_reference
      @_ref_resources.each do |ref|
        if ref.class == Iroha::Builder::Simple::Reference then
          resource = ref.resolve
        else
          resource = ref
        end
        if resource.nil?
          fail "Error: can not found register Reference(#{ref.args})"
        end
        _add_connection(resource._owner_module._id, resource._owner_table._id, resource._id)
      end
    end
    define_method('<=') do |regs|
      state = @_owner_table._on_state
      fail "Error: not on state"           if state.nil?
      fail "Error: source is not register" if regs.class != Iroha::Builder::Simple::IRegister
      state.__add_instruction(self, [], [], [regs], [])
      return self
    end
  end

end