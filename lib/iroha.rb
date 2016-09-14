module Iroha
  require_relative 'iroha/i_design'
  require_relative 'iroha/i_channel'
  require_relative 'iroha/i_module'
  require_relative 'iroha/i_table'
  require_relative 'iroha/i_resource'
  require_relative 'iroha/i_register'
  require_relative 'iroha/i_state'
  require_relative 'iroha/i_instruction'
  require_relative 'iroha/i_value_type'

  def self.parent_class(klass)
    class_name_list = klass.to_s.split(/::/)
    class_name_list.pop
    parent_class = Object;
    class_name_list.each{|name| parent_class = parent_class.const_get(name)}
    return parent_class
  end

  def self.franchise_class(franchisor, franchisee)
    franchisee.const_set(:IDesign     , Class.new(franchisor.const_get(:IDesign     )))
    franchisee.const_set(:IChannel    , Class.new(franchisor.const_get(:IChannel    )))
    franchisee.const_set(:IModule     , Class.new(franchisor.const_get(:IModule     )))
    franchisee.const_set(:ITable      , Class.new(franchisor.const_get(:ITable      )))
    franchisee.const_set(:IRegister   , Class.new(franchisor.const_get(:IRegister   )))
    franchisee.const_set(:IResource   , Class.new(franchisor.const_get(:IResource   )))
    franchisee.const_set(:IState      , Class.new(franchisor.const_get(:IState      )))
    franchisee.const_set(:IInstruction, Class.new(franchisor.const_get(:IInstruction)))
    franchisee.const_set(:IValueType  , Class.new(franchisor.const_get(:IValueType  )))
    franchisor_resource_class = franchisor.const_get(:IResource)
    ObjectSpace.each_object(Class).select{|klass| klass.superclass == franchisor_resource_class}.each do |res_class|
      class_name = res_class.to_s.split(/::/).last.to_sym
      franchisee.const_get(:IResource).const_set(class_name, Class.new(res_class))
      ## p "== #{class_name} == #{franchisee.const_get(:IResource).const_get(class_name)}"
    end
    franchisee.const_get(:IResource).const_set(:Params, Class.new(franchisor_resource_class.const_get(:Params)))
  end

end
  
