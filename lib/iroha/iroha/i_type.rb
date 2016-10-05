module Iroha

  class IType
    def self.convert_from(type)
      class_name   = type.class.to_s.split(/::/).last
      parent_class = Iroha.parent_class(self)
      return parent_class.const_get(:Type).const_get(class_name).convert_from(type)
    end
  end

end
