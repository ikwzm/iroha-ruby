module Iroha

  class IModule

    attr_reader   :id, :name, :parent_id, :params, :tables
    attr_reader   :owner_design, :owner_module

    def initialize(id, name, parent_id, params, table_list)
      @owner_design = nil               ## TYPE: Iroha::Design
      @owner_module = nil               ## TYPE: Iroha::Module
      @id           = id                ## TYPE: number
      set_name(name)                    ## TYPE: symbol or number or nil
      @parent_id    = parent_id         ## TYPE: number
      @params       = params            ## TYPE: Iroha::Resource::Params
      @tables       = Hash.new          ## TYPE: Hash {id:number, table:Iroha::ITable}
      table_list.each {|table| add_table(table)}
    end

    def set_name(name)
      if name.class == String then
        if name == "" then
          @name = nil
        else
          @name = name.to_sym
        end
      else
          @name = name
      end
      return @name
    end

    def set_owner(owner_design)
      @owner_design = owner_design
      if @parent_id != nil then
        @owner_module = @owner_design.find_module(@parent_id)
        abort "(MODULE #{@name} (PARENT #{@parent_id})...) unknown parent module." if @owner_module == nil
      end
      @tables.values.each{|table| table.set_owner(owner_design, self)}
    end

    def add_table(table)
      abort "(TABLE #{table.id} ... ) is multi definition." if @tables.key?(table.id)
      @tables[table.id] = table
      table.set_owner(@owner_design, self)
    end

    def find_resource(tbl_id, res_id)
      if @tables.key?(tbl_id) then
        return @tables[tbl_id].find_resource(res_id)
      else
        return nil
      end
    end

    def find_register(tbl_id, reg_id)
      if @tables.key?(tbl_id) then
        return @tables[tbl_id].find_register(res_id)
      else
        return nil
      end
    end

    def to_exp(indent)
      return indent + "(MODULE #{@id} #{@name}\n" +
             @params.to_exp(indent+"  ") + "\n" +
             ((@owner_module != nil)? indent + "  (PARENT #{@owner_module.id})\n" : "") +
             @tables.values.map{|table| table.to_exp(indent+"  ")}.join("\n") + "\n" +
             indent + ")"
    end

    def id_to_str
      return "IModule[#{@id}]"
    end

    def self.convert_from(mod)
      parent_class = Iroha.parent_class(self)
      table_class  = parent_class.const_get(:ITable)
      param_class  = parent_class.const_get(:IResource).const_get(:Params)
      id           = mod.id
      name         = mod.name
      parent_id    = (mod.owner_module != nil) ? mod.owner_module.id : nil
      params       = param_class.new
      mod.params.each_pair{ |key, value| params[key.clone] = value.clone }
      table_list = mod.tables.values.map{|table| table_class.convert_from(table)}
      self.new(id, name, parent_id, params, table_list)
    end

  end

end
