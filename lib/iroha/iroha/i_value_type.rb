module Iroha

  class IValueType
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

    def self.convert_from(value_type)
      self.new(value_type._is_signed, value_type._width)
    end

  end

end
