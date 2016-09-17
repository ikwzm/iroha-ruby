module Iroha

  class IDesign

    attr_reader :_params, :_modules, :_channels, :_resource_classes

    def initialize
      @_params           = Iroha::IParams.new            ## TYPE: Iroha::IParams
      @_modules          = Hash.new                      ## TYPE: Hash {id:number, module:Iroha::IModule}
      @_channels         = Hash.new                      ## TYPE: Hash {id:number, channel:Iroha::IChannel}
      @_resource_classes = Hash[Iroha::STANDARD_RESOURSE_CLASSES.map{|res_class| [res_class::CLASS_NAME, res_class]}]
    end

    def _add_param(param)
      @_params.update(param)
    end

    def _add_module(mod)
      abort "(MODULE #{mod._id} #{mod._name} ... ) is multi definition." if @_modules.key?(mod._id)
      @_modules[mod._id] = mod
      mod._set_owner(self)
    end

    def _add_channel(channel)
      abort "(CHANNEL #{channel._id} ... ) is multi definition." if @_channels.key?(channel._id)
      @_channels[channel._id] = channel
      channel._set_owner(self)
    end

    def _find_module(module_id)
      return @_modules.fetch(module_id, nil)
    end

    def _find_table(module_id, table_id)
      if @_modules.key?(module_id) then
        return @_modules[module_id]._find_table(table_id)
      else
        return nil
      end
    end

    def _find_resource(module_id, table_id, resource_id)
      if @_modules.key?(module_id) then
        return @_modules[module_id]._find_resource(table_id, resource_id)
      else
        return nil
      end
    end
    
    def _find_register(module_id, table_id, register_id)
      if @_modules.key?(module_id) then
        return @_modules[module_id]._find_register(table_id, register_id)
      else
        return nil
      end
    end
    
    def to_exp(indent)
      return @_params._to_exp(indent) + "\n" +
             @_channels.values.map{|c| c._to_exp(indent)}.join("\n") + "\n" +
             @_modules.values.map{ |m| m._to_exp(indent)}.join("\n")
    end

    def self.convert_from(design)
      new_design    = self.new
      parent_class  = Iroha.parent_class(self)
      module_class  = parent_class.const_get(:IModule )
      channel_class = parent_class.const_get(:IChannel)
      design._params.each_pair {|key, value|
        new_design._add_param({key => value})
      }
      design._modules.values.each {|mod|
        new_design._add_module(module_class.convert_from(mod))
      }
      design._channels.values.each {|channel|
        new_design._add_channel(channel_class.convert_from(channel))
      }
      return new_design
    end

  end

end
