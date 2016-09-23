module Iroha

  class IModule

    attr_reader   :_id, :_name, :_parent_id, :_params, :_tables
    attr_reader   :_owner_design, :_owner_module

    def initialize(id, name, parent_id, params, table_list)
      @_owner_design = nil               ## TYPE: Iroha::Design
      @_owner_module = nil               ## TYPE: Iroha::Module
      @_id           = id                ## TYPE: number
      _set_name(name)                    ## TYPE: symbol or number or nil
      @_parent_id    = parent_id         ## TYPE: number
      @_params       = params            ## TYPE: Iroha::IParams
      @_tables       = Hash.new          ## TYPE: Hash {id:number, table:Iroha::ITable}
      table_list.each {|table| _add_table(table)}
    end

    def _set_name(name)
      if name.class == String then
        if name == "" then
          @_name = nil
        else
          @_name = name.to_sym
        end
      else
          @_name = name
      end
      return @_name
    end

    def _set_owner(owner_design)
      @_owner_design = owner_design
      if @_parent_id.nil? == false then
        @_owner_module = @_owner_design._find_module(@_parent_id)
        abort "(MODULE #{@_name} (PARENT #{@_parent_id})...) unknown parent module." if @_owner_module.nil?
      end
      @_tables.values.each{|table| table._set_owner(owner_design, self)}
    end

    def _add_table(table)
      abort "(TABLE #{table._id} ... ) is multi definition." if @_tables.key?(table._id)
      @_tables[table._id] = table
      table._set_owner(@_owner_design, self)
      return table
    end

    def _find_table(tab_id)
      return @_tables[tab_id]
    end
    
    def _find_resource(tbl_id, res_id)
      if @_tables.key?(tbl_id) then
        return @_tables[tbl_id]._find_resource(res_id)
      else
        return nil
      end
    end

    def _find_register(tbl_id, reg_id)
      if @_tables.key?(tbl_id) then
        return @_tables[tbl_id]._find_register(reg_id)
      else
        return nil
      end
    end

    def _to_exp(indent)
      return indent + "(MODULE #{@_id} #{@_name}\n" +
             @_params._to_exp(indent+"  ") + "\n" +
             ((@_owner_module.nil? == false) ? indent + "  (PARENT #{@_owner_module._id})\n" : "") +
             @_tables.values.map{|table| table._to_exp(indent+"  ")}.join("\n") + "\n" +
             indent + ")"
    end

    def _id_to_str
      return "IModule[#{@_id}]"
    end

    def self.convert_from(mod)
      parent_class = Iroha.parent_class(self)
      table_class  = parent_class.const_get(:ITable)
      params_class = parent_class.const_get(:IParams)
      id           = mod._id
      name         = mod._name
      parent_id    = (mod._owner_module.nil? == false) ? mod._owner_module._id : nil
      params       = params_class.convert_from(mod._params)
      table_list   = mod._tables.values.map{|table| table_class.convert_from(table)}
      self.new(id, name, parent_id, params, table_list)
    end

  end

end
