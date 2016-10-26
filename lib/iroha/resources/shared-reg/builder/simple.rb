module Iroha::Builder::Simple::Resource

  class SharedRegisterReader
    attr_accessor :_ref_resources

    TABLE_PROC = Proc.new {
      def SharedRegisterReader(**args)
        fail "Error: #{__method__} illegal argument size" if args.size != 1
        name, type = args.shift
        if type._width.nil? then
          params = {:INPUT => name}
        else
          params = {:INPUT => name, :WIDTH => type._width}
        end
        resource = __add_resource(:SharedRegisterReader, name, [], [type], params, {:"SHARED-REG" => nil})
        if type._assign_value.nil?
          resource._ref_resources = []
        else
          resource._ref_resources = [type._assign_value]
        end
        return resource
      end
    }

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
      fail "Error: can not connect SharedRegister(#{_id_to_str}) to #{regs._id_to_str}" if regs.class != SharedRegister and regs.class != CurrentState
      self._add_connection(regs._owner_module._id, regs._owner_table._id, regs._id)
      regs._add_connection(self._owner_module._id, self._owner_table._id, self._id)
      return self
    end
  end

  class SharedRegister
    attr_accessor :_ref_resources

    TABLE_PROC = Proc.new {
      def SharedRegister(**args)
        fail "Error: #{__method__} illegal argument size" if args.size != 1
        name, type = args.shift
        params = {:OUTPUT => name}
        if type._width.nil? == false then
          params[:WIDTH] = type._width
        end
        if type._assign_value.kind_of?(Integer) then
          params[:"DEFAULT-VALUE"] = type._assign_value
        end
        resource = __add_resource(:SharedRegister, name, [type], [], params, nil)
        resource._ref_resources = []
        return resource
      end
    }

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
