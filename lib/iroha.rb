module Iroha
  require_relative 'iroha/iroha/i_design'
  require_relative 'iroha/iroha/i_channel'
  require_relative 'iroha/iroha/i_module'
  require_relative 'iroha/iroha/i_table'
  require_relative 'iroha/iroha/i_resource'
  require_relative 'iroha/iroha/i_register'
  require_relative 'iroha/iroha/i_state'
  require_relative 'iroha/iroha/i_instruction'
  require_relative 'iroha/iroha/i_value_type'
  require_relative 'iroha/iroha/i_params'
  require_relative 'iroha/iroha/methods'

  STANDARD_RESOURCE_LIST    = Dir::glob(File.expand_path(File.dirname(__FILE__)) + "/iroha/resources/*").map{|f| File.basename(f)}
  STANDARD_RESOURCE_LIST.each do |resource|
    require_relative "iroha/resources/#{resource}/resource"
  end
  STANDARD_RESOURSE_CLASSES = ObjectSpace.each_object(Class).select{|klass| klass.superclass == Iroha::IResource}
end
  
