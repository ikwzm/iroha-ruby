module Iroha::Resource

  class SubModuleTask     < Iroha::IResource
    CLASS_NAME   = "sub-module-task"
    IS_EXCLUSIVE = true
    def initialize(id, input_types, output_types, params, option)
      super(CLASS_NAME, IS_EXCLUSIVE, id, input_types, output_types, params, option)
    end
  end

  class SubModuleTaskCall < Iroha::IResource
    CLASS_NAME   = "sub-module-task-call"
    OPTION_NAME  = "CALLEE-TABLE".to_sym
    IS_EXCLUSIVE = true

    def initialize(id, input_types, output_types, params, option)
      if option.key?(OPTION_NAME) then
        if    option[OPTION_NAME].nil? then
          super(CLASS_NAME, IS_EXCLUSIVE, id, input_types, output_types, params, nil)
          @_callee_table_id = nil
        elsif option[OPTION_NAME].size == 2 and
              option[OPTION_NAME][0].kind_of?(Integer) and
              option[OPTION_NAME][1].kind_of?(Integer) then
          super(CLASS_NAME, IS_EXCLUSIVE, id, input_types, output_types, params, nil)
          @_callee_table_id = {:MODULE => option[OPTION_NAME][0], :TABLE => option[OPTION_NAME][1]}
        else
          super(CLASS_NAME, IS_EXCLUSIVE, id, input_types, output_types, params, option)
        end
      else
          super(CLASS_NAME, IS_EXCLUSIVE, id, input_types, output_types, params, option)
      end
    end

    def _option_clone
      if @_callee_table_id.class == Hash then
        return {OPTION_NAME => [@_callee_table_id[:MODULE], @_callee_table_id[:TABLE]]}
      else
        return {OPTION_NAME => nil}
      end
    end

    def _option_to_exp
      table = _get_callee_table()
      fail "Not Found Callee Table in #{_id_to_str}" if table.nil?
      return "(#{OPTION_NAME} #{table._owner_module._id} #{table._id})"
    end

    def _set_callee_table(table)
      @_callee_table_id = {:MODULE => table._owner_module._id, :TABLE => table._id}
    end

    def _get_callee_table
      if @_callee_table_id.class == Hash then
        return @_owner_design._find_table(@_callee_table_id[:MODULE], @_callee_table_id[:TABLE])
      else
        return nil
      end
    end
  end

end
