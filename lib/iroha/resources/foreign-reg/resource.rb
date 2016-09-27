module Iroha::Resource
  
  class ForeignReg < Iroha::IResource
    CLASS_NAME   = "foreign-reg"
    OPTION_NAME  = "FOREIGN-REG".to_sym
    IS_EXCLUSIVE = true

    def initialize(id, input_types, output_types, params, option)
      if option.key?(OPTION_NAME) then
        if    option[OPTION_NAME].nil? then
          super(CLASS_NAME, IS_EXCLUSIVE, id, input_types, output_types, params, nil)
          @_foreign_register_id = nil
        elsif option[OPTION_NAME].size == 3            and
              option[OPTION_NAME][0].kind_of?(Integer) and
              option[OPTION_NAME][1].kind_of?(Integer) and
              option[OPTION_NAME][2].kind_of?(Integer) then
          super(CLASS_NAME, IS_EXCLUSIVE, id, input_types, output_types, params, nil)
          @_foreign_register_id = {:MODULE   => option[OPTION_NAME][0],
                                   :TABLE    => option[OPTION_NAME][1],
                                   :REGISTER => option[OPTION_NAME][2]}
        else
          super(CLASS_NAME, IS_EXCLUSIVE, id, input_types, output_types, params, option)
        end
      else
          super(CLASS_NAME, IS_EXCLUSIVE, id, input_types, output_types, params, option)
      end
    end

    def _option_clone
      if @_foreign_register_id.class == Hash then
        return {OPTION_NAME => [@_foreign_register_id[:MODULE  ],
                                @_foreign_register_id[:TABLE   ],
                                @_foreign_register_id[:REGISTER]]}
      else
        return {OPTION_NAME => nil}
      end
    end

    def _option_to_exp
      register = _get_foreign_register()
      fail "Not Found Register(#{@_foreign_register_id}) in #{_id_to_str}" if register.nil?
      return "(#{OPTION_NAME} #{register._owner_module._id} #{register._owner_table._id} #{register._id})"
    end

    def _set_foreign_register(register)
      @_foreign_register_id = {:MODULE   => register._owner_module._id,
                               :TABLE    => register._owner_table._id,
                               :REGISTER => register._id}
    end

    def _get_foreign_register
      if @_foreign_register_id.class == Hash then
        return @_owner_design._find_register(@_foreign_register_id[:MODULE  ],
                                             @_foreign_register_id[:TABLE   ],
                                             @_foreign_register_id[:REGISTER])
      else
        return nil
      end
    end

  end

end
