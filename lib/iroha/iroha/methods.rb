module Iroha

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
    franchisee.const_set(:IType       , Class.new(franchisor.const_get(:IType       )))
    franchisee.const_set(:IParams     , Class.new(franchisor.const_get(:IParams     )))
    franchisee.const_set(:Resource    , Module.new)
    franchisor_resource_class = franchisor.const_get(:IResource)
    ObjectSpace.each_object(Class).select{|klass| klass.superclass == franchisor_resource_class}.each do |res_class|
      class_name = res_class.to_s.split(/::/).last.to_sym
      if class_name != :Resource then
        franchisee.const_get(:Resource).const_set(class_name, Class.new(res_class))
        # p "== #{class_name} == #{franchisee.const_get(:Resource).const_get(class_name)}"
      end
    end
    franchisee.const_set(:Type, Module.new)
    franchisor_type_class = franchisor.const_get(:IType)
    ObjectSpace.each_object(Class).select{|klass| klass.superclass == franchisor_type_class}.each do |type_class|
      class_name = type_class.to_s.split(/::/).last.to_sym
      franchisee.const_get(:Type).const_set(class_name, Class.new(type_class))
    end
  end

end
