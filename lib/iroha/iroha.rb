module Iroha
  require_relative 'iroha/i_design'
  require_relative 'iroha/i_channel'
  require_relative 'iroha/i_module'
  require_relative 'iroha/i_table'
  require_relative 'iroha/i_resource'
  require_relative 'iroha/i_register'
  require_relative 'iroha/i_state'
  require_relative 'iroha/i_instruction'
  require_relative 'iroha/i_type'
  require_relative 'iroha/i_params'
  require_relative 'iroha/methods'

  module Resource
  end
  module Type
  end

  BASE_CLASS_NAME_LIST = [:IDesign, :IChannel, :IModule, :ITable, :IRegister, :IResource, :IState, :IInstruction, :IType, :IParams]

  RESOURCE_PATH_LIST = Dir::glob(File.expand_path(File.dirname(__FILE__)) + "/resources/*").map{|f| "resources/" + File.basename(f)}
  TYPE_PATH_LIST     = Dir::glob(File.expand_path(File.dirname(__FILE__)) + "/types/*"    ).map{|f| "types/"     + File.basename(f)}
  RESOURCE_PATH_LIST.each{ |path| require_relative "#{path}/resource" }
  TYPE_PATH_LIST    .each{ |path| require_relative "#{path}/type"     }
  RESOURSE_CLASSES   = Iroha::Resource.constants.map{|c| Iroha::Resource.const_get(c)}
  TYPE_CLASSES       = Iroha::Type    .constants.map{|c| Iroha::Type    .const_get(c)}

end

