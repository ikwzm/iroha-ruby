module Iroha

  class IType
    def self.convert_from(type)
      class_name   = type.class.to_s.split(/::/).last
      parent_class = Iroha.parent_class(self)
      return parent_class.const_get(:Type).const_get(class_name).convert_from(type)
    end
  end

  module Type

    class Numeric < Iroha::IType
      attr_reader :_is_signed, :_width
      def initialize(is_signed, width)
        @_is_signed = is_signed
        @_width     = width
      end

      def _to_exp
        if @_is_signed then
          return "(INT #{@_width})"
        else
          return "(UINT #{@_width})"
        end
      end

      def self.convert_from(type)
        self.new(type._is_signed, type._width)
      end
      
    end

    class State < Iroha::IType
      attr_reader :_module_id, :_table_id
      attr_reader :_width
      def initialize(module_id, table_id)
        @_module_id = module_id
        @_table_id  = table_id
        @_width     = nil
      end

      def _to_exp
        return "(STATE #{@_module_id} #{@_table_id})"
      end

      def self.convert_from(type)
        self.new(type._module_id, type._table_id)
      end
    end

    def self.convert_from(type)
      class_name   = type.class.to_s.split(/::/).last
      parent_class = Iroha.parent_class(self)
      return parent_class.const_get(class_name).convert_from(type)
    end

  end

end
