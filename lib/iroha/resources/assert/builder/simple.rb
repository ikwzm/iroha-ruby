module Iroha::Builder::Simple::Resource

  class Assert
    SINGLETON  = true
    STATE_PROC = Proc.new {
      def Assert(*regs)
        resource = @_owner_table.__add_resource(:Assert, nil, [], [], {}, {})
        return __add_instruction(resource, [], [], regs , [])
      end
    }
  end

end
