module Iroha

  class IChannel

    attr_reader :id, :type
    attr_reader :r_module_id, :r_table_id, :r_resource_id
    attr_reader :w_module_id, :w_table_id, :w_resource_id
    attr_reader :owner_design

    def initialize(id, type, r_module_id, r_table_id, r_resource_id, w_module_id, w_table_id, w_resource_id)
      @id            = id
      @type          = type
      @r_module_id   = r_module_id
      @r_table_id    = r_table_id
      @r_resource_id = r_resource_id
      @w_module_id   = w_module_id
      @w_table_id    = w_table_id
      @w_resource_id = w_resource_id
      @owner_design  = nil
    end

    def set_owner(owner_design)
      @owner_design  = owner_design
    end
    
    def to_exp(indent)
      abort "Undefined Owner Design at (CHANNEL #{@id} ...)"              if @owner_design == nil
      r_res = @owner_design.find_resource(r_module_id, r_table_id, r_resource_id)
      w_res = @owner_design.find_resource(w_module_id, w_table_id, w_resource_id)
      abort "Not Found Resouce (#{r_module_id} #{r_table_id} #{r_resource_id}) at (CHANNEL #{@id} ...)" if r_res == nil 
      abort "Not Found Resouce (#{w_module_id} #{w_table_id} #{w_resource_id}) at (CHANNEL #{@id} ...)" if w_res == nil
      r_exp = "(#{r_res.owner_module.id} #{r_res.owner_table.id} #{r_res.id})"
      w_exp = "(#{w_res.owner_module.id} #{w_res.owner_table.id} #{w_res.id})"
      return indent + "(CHANNEL #{@id} #{@type.to_exp} #{r_exp} #{w_exp})"
    end

    def self.convert_from(channel)
      self.new(
         channel.id           ,
         channel.type.clone   ,
         channel.r_module_id  ,
         channel.r_table_id   ,
         channel.r_resource_id,
         channel.w_module_id  ,
         channel.w_table_id   ,
         channel.w_resource_id)
    end

  end

end
