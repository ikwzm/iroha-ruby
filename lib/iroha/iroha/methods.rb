module Iroha

  def self.parent_class(klass)
    class_name_list = klass.to_s.split(/::/)
    class_name_list.pop
    parent_class = Object;
    class_name_list.each{|name| parent_class = parent_class.const_get(name)}
    return parent_class
  end

  DEBUG = false

  def self.franchise_class(franchisee, franchisor)

    def self.p_info(message); p "== " + message if DEBUG == true; end

    p_info("#{self}.franchise_class(#{franchisee}, #{franchisor}) start")

    Iroha::BASE_CLASS_NAME_LIST.each do |class_name|
      p_info("  class  #{franchisee}::#{class_name} < #{franchisor.const_get(class_name)}")
      franchisee.const_set(class_name, Class.new(franchisor.const_get(class_name)))
      p_info("  end")
    end

    p_info("  module #{franchisee}::Resource")
    franchisee.const_set(:Resource, Module.new)
    p_info("  end")

    p_info("  module #{franchisee}::Type")
    franchisee.const_set(:Type    , Module.new)
    p_info("  end")

    franchisor_resource_module = franchisor.const_get(:Resource)
    franchisor_resource_list   = franchisor_resource_module.constants.map{|c| franchisor_resource_module.const_get(c)}
    franchisor_resource_list.each do |res_class|
      class_name = res_class.to_s.split(/::/).last.to_sym
      p_info("  class  #{franchisee.const_get(:Resource)}::#{class_name} < #{res_class}")
      franchisee.const_get(:Resource).const_set(class_name, Class.new(res_class))
      p_info("  end")
    end

    franchisor_type_module = franchisor.const_get(:Type)
    franchisor_type_list   = franchisor_type_module.constants.map{|c| franchisor_type_module.const_get(c)}
    franchisor_type_list.each do |type_class|
      class_name = type_class.to_s.split(/::/).last.to_sym
      p_info("  class #{franchisee.const_get(:Type)}::#{class_name} < #{type_class}")
      franchisee.const_get(:Type).const_set(class_name, Class.new(type_class))
      p_info("  end")
    end

    p_info("#{self}.franchise_class(#{franchisee}, #{franchisor}) done")
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

    if module_object.const_defined?(:IType) then
      type_module = class_object.const_get(:Type)
      type_list   = type_module.constants.map{|c| type_module.const_get(c)}
      type_list.each do |type_class|
        type_class.include(module_object.const_get(:IType))
      end
    end

  end

end
