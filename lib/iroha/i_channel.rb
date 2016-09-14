module Iroha

  class IChannel

    attr_reader :_id, :_type
    attr_reader :_r_module_id, :_r_table_id, :_r_resource_id
    attr_reader :_w_module_id, :_w_table_id, :_w_resource_id
    attr_reader :_owner_design

    def initialize(id, type, r_module_id, r_table_id, r_resource_id, w_module_id, w_table_id, w_resource_id)
      @_id            = id
      @_type          = type
      @_r_module_id   = r_module_id
      @_r_table_id    = r_table_id
      @_r_resource_id = r_resource_id
      @_w_module_id   = w_module_id
      @_w_table_id    = w_table_id
      @_w_resource_id = w_resource_id
      @_owner_design  = nil
    end

    def _set_owner(owner_design)
      @_owner_design  = owner_design
    end
    
    def _to_exp(indent)
      abort "Undefined Owner Design at (CHANNEL #{@_id} ...)" if @_owner_design == nil
      r_res = @_owner_design._find_resource(@_r_module_id, @_r_table_id, @_r_resource_id)
      w_res = @_owner_design._find_resource(@_w_module_id, @_w_table_id, @_w_resource_id)
      abort "Not Found Resouce (#{@_r_module_id} #{@_r_table_id} #{@_r_resource_id}) at (CHANNEL #{@_id} ...)" if r_res == nil 
      abort "Not Found Resouce (#{@_w_module_id} #{@_w_table_id} #{@_w_resource_id}) at (CHANNEL #{@_id} ...)" if w_res == nil
      r_exp = "(#{r_res._owner_module._id} #{r_res._owner_table._id} #{r_res._id})"
      w_exp = "(#{w_res._owner_module._id} #{w_res._owner_table._id} #{w_res._id})"
      return indent + "(CHANNEL #{@_id} #{@_type._to_exp} #{r_exp} #{w_exp})"
    end

    def self.convert_from(channel)
      self.new(
         channel._id           ,
         channel._type.clone   ,
         channel._r_module_id  ,
         channel._r_table_id   ,
         channel._r_resource_id,
         channel._w_module_id  ,
         channel._w_table_id   ,
         channel._w_resource_id)
    end

  end

end
