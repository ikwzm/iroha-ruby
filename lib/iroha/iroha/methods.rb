module Iroha

  def self.parent_class(klass)
    class_name_list = klass.to_s.split(/::/)
    class_name_list.pop
    parent_class = Object;
    class_name_list.each{|name| parent_class = parent_class.const_get(name)}
    return parent_class
  end

  def self.franchise_class(franchisee, franchisor)

    Iroha::BASE_CLASS_NAME_LIST.each do |class_name|
      franchisee.const_set(class_name, Class.new(franchisor.const_get(class_name)))
    end

    franchisee.const_set(:Resource, Module.new)
    franchisee.const_set(:Type    , Module.new)

    franchisor_resource_class = franchisor.const_get(:IResource)
    ObjectSpace.each_object(Class).select{|klass| klass.superclass == franchisor_resource_class}.each do |res_class|
      class_name = res_class.to_s.split(/::/).last.to_sym
      if class_name != :IResource then
        franchisee.const_get(:Resource).const_set(class_name, Class.new(res_class))
        # p "== #{class_name} == #{franchisee.const_get(:Resource).const_get(class_name)}"
      end
    end

    franchisor_type_class = franchisor.const_get(:IType)
    ObjectSpace.each_object(Class).select{|klass| klass.superclass == franchisor_type_class}.each do |type_class|
      class_name = type_class.to_s.split(/::/).last.to_sym
      if class_name != :IType then
        franchisee.const_get(:Type).const_set(class_name, Class.new(type_class))
      end
    end

  end

  def self.include_module(class_object, module_object)

    Iroha::BASE_CLASS_NAME_LIST.each do |class_name|
      if module_object.const_defined?(class_name) then
        class_object.const_get(class_name).include(module_object.const_get(class_name))
      end
    end

    if module_object.const_defined?(:IResource) then
      resource_module = class_object.const_get(:Resource)
      resource_list   = resource_module.constants.map{|c| resource_module.const_get(c)}
      resource_list.each do |resource|
        resource.include(module_object.const_get(:IResource))
      end
    end

  end

end
