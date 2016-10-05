module Iroha::Builder::Simple::Resource

  class Print 
    SINGLETON  = true
    STATE_PROC = Proc.new {
      def Print(*regs)
        resource = @_owner_table.__add_resource(:Print, nil, [], [], {}, {})
        return __add_instruction(resource, [], [], regs , [])
      end
    }
  end

end
