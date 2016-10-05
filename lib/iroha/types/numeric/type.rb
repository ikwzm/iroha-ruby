module Iroha::Type

  class Signed   < Iroha::IType
    CLASS_NAME = "INT"
    attr_reader :_is_signed, :_width

    def initialize(*options)
      if options.size == 1 and
         options[0].kind_of?(Integer) then
        @_width     = options[0]
        @_is_signed = true
      else
        exp_str = [CLASS_NAME].concat(options).join(" ")
        fail "(#{exp_str}) is invalid option."
      end
    end

    def _to_exp
      return "(#{CLASS_NAME} #{@_width})"
    end

    def self.convert_from(type)
      self.new(type._width)
    end

  end

  class Unsigned < Iroha::IType
    CLASS_NAME = "UINT"
    attr_reader :_is_signed, :_width

    def initialize(*options)
      if options.size == 1 and
         options[0].kind_of?(Integer) then
        @_width     = options[0]
        @_is_signed = false
      else
        exp_str = [CLASS_NAME].concat(options).join(" ")
        fail "(#{exp_str}) is invalid option."
      end
    end

    def _to_exp
      return "(#{CLASS_NAME} #{@_width})"
    end

    def self.convert_from(type)
      self.new(type._width)
    end
  end
  
end

