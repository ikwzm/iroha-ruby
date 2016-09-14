module Iroha

  class IDesign

    attr_reader :params, :modules, :channels, :resource_classes

    def initialize
      @params           = Iroha::IResource::Params.new  ## TYPE: Iroha::IResource::Params
      @modules          = Hash.new                      ## TYPE: Hash {id:number, module:Iroha::IModule}
      @channels         = Hash.new                      ## TYPE: Hash {id:number, channel:Iroha::IChannel}
      @resource_classes = Hash[Iroha::STANDARD_RESOURSE_CLASSES.map{|res_class| [res_class::CLASS_NAME, res_class]}]
    end

    def add_param(param)
      @params.update(param)
    end

    def add_module(mod)
      abort "(MODULE #{mod.id} #{mod.name} ... ) is multi definition." if @modules.key?(mod.id)
      @modules[mod.id] = mod
      mod.set_owner(self)
    end

    def add_channel(channel)
      abort "(CHANNEL #{channel.id} ... ) is multi definition." if @channels.key?(channel.id)
      @channels[channel.id] = channel
      channel.set_owner(self)
    end

    def find_module(module_id)
      return @modules.fetch(module_id, nil)
    end

    def find_table(module_id, table_id)
      if @modules.key?(module_id) then
        return @modules[module_id].find_table(table_id)
      else
        return nil
      end
    end

    def find_resource(module_id, table_id, resource_id)
      if @modules.key?(module_id) then
        return @modules[module_id].find_resource(table_id, resource_id)
      else
        return nil
      end
    end
    
    def find_register(module_id, table_id, register_id)
      if @modules.key?(module_id) then
        return @modules[module_id].find_register(table_id, register_id)
      else
        return nil
      end
    end
    
    def to_exp(indent)
      return @params.to_exp(indent) + "\n" +
             @channels.values.map{|c| c.to_exp(indent)}.join("\n") + "\n" +
             @modules.values.map{ |m| m.to_exp(indent)}.join("\n")
    end

    def self.convert_from(design)
      new_design    = self.new
      parent_class  = Iroha.parent_class(self)
      module_class  = parent_class.const_get(:IModule )
      channel_class = parent_class.const_get(:IChannel)
      design.params.each_pair {|key, value|
        new_design.add_param({key => value})
      }
      design.modules.values.each {|mod|
        new_design.add_module(module_class.convert_from(mod))
      }
      design.channels.values.each {|channel|
        new_design.add_channel(channel_class.convert_from(channel))
      }
      return new_design
    end

  end

end
