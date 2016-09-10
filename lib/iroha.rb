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

end
  
