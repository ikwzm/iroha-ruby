module Iroha::Builder::Simple::Resource

  class CurrentState

    attr_accessor :_ref_resources

    TABLE_PROC = Proc.new {
      def CurrentState(name)
        params = {:OUTPUT => name}
        type   = Type::State.new(@_owner_module._id, @_id)
        resource = __add_resource(:CurrentState, name, [], [type], params, nil)
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
  end

end
