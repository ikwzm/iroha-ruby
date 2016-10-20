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

    def _min
      return 0-(2**(@_width-1))
    end

    def _max
      return (2**(@_width-1)-1)
    end

    define_method('==') do |type|
      return false if type.kind_of?(Signed) == false
      return false if type._width != @_width
      return true
    end

    def self.convert_from(type)
      self.new(type._width)
    end

    def self.calc_width(*values)
      min   = values.min
      max   = values.max
      width = 1
      while ((2**(width-1)-1 < max) or (0-2**(width-1) > min)) do
        width += 1
      end
      return width
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

    define_method('==') do |type|
      return false if type.kind_of?(Unsigned) == false
      return false if type._width != @_width
      return true
    end

    def _to_exp
      return "(#{CLASS_NAME} #{@_width})"
    end

    def _min
      return 0
    end

    def _max
      return 2**(@_width)-1
    end

    def self.calc_width(*values)
      min   = values.min
      max   = values.max
      width = 1
      while(2**width-1 < max) do
        width += 1
      end
      return width
    end

    def self.convert_from(type)
      self.new(type._width)
    end
  end
  
end

