module Iroha

  class IValueType
    attr_reader :is_signed, :width
    def initialize(is_signed, width)
      @is_signed = is_signed
      @width     = width
    end

    def to_exp
      if @is_signed then
        return "(INT #{@width})"
      else
        return "(UINT #{@width})"
      end
    end

    def self.convert_from(value_type)
      self.new(value_type.is_signed, value_type.width)
    end

  end

end
