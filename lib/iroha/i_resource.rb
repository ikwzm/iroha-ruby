module Iroha

  class IResource
    attr_reader :class_name, :is_exclusive
    attr_reader :id, :input_types, :output_types, :params, :option
    attr_reader :owner_design, :owner_module, :owner_table
    
    def initialize(class_name, is_exclusive, id, input_types, output_types, params, option)
      @class_name   = class_name      ## TYPE: string
      @is_exclusive = is_exclusive    ## TYPE: boolean
      @id           = id              ## TYPE: id
      @input_types  = input_types     ## TYPE: Array[Iroha::IValueType]
      @output_types = output_types    ## TYPE: Array[Iroha::IValueType]
      @params       = params          ## TYPE: Iroha::IResource::Params
      @option       = Hash.new;       ## Type: Hash {name:string, value:string or number}
      @owner_design = nil
      @owner_module = nil
      @owner_table  = nil
      if  option.class == Hash  then
        @option.update(option)
      end
    end

    def set_owner(owner_design, owner_module, owner_table)
      @owner_design = owner_design
      @owner_module = owner_module
      @owner_table  = owner_table
    end

    def set_owner_table(owner_table)
      @owner_table  = owner_table
    end

    def to_exp(indent)
      option_param = @option.to_a.map{|pair|
        if    (pair[0] == :ARRAY) then
          addr_width = pair[1][:ADDR_WIDTH]
          value_type = pair[1][:VALUE_TYPE].to_exp
          ref        = (pair[1][:EXTERNAL]) ? "EXTERNAL" : "INTERNAL"
          ram        = (pair[1][:RAM     ]) ? "RAM"      : "ROM"
          "(ARRAY #{addr_width} #{value_type} #{ref} #{ram})"
        elsif (pair[0] == :"CALLEE-TABLE") then
          "(CALLEE-TABLE #{pair[1][:MODULE]} #{pair[1][:TABLE]})"
        elsif (pair[0] == :"FOREIGN-REG" ) then
          "(FOREIGN-REG  #{pair[1][:MODULE]} #{pair[1][:TABLE]} #{pair[1][:REGISTER]})"
        else
          ""
        end
      }
      return indent + "(RESOURCE #{@id} #{@class_name} " +
             "(" + @input_types.map{ |t|t.to_exp}.join(" ") + ") " +
             "(" + @output_types.map{|t|t.to_exp}.join(" ") + ") " +
             @params.to_exp("") + option_param.join("") + ")"
    end

    def self.convert_from(resource)
      parent_class = Iroha.parent_class(Iroha.parent_class(self))
      params_class = parent_class.const_get(:IResource).const_get(:Params)
      type_class   = parent_class.const_get(:IValueType)
      id           = resource.id
      input_types  = resource.input_types.map{ |value_type| type_class.convert_from(value_type)}
      output_types = resource.output_types.map{|value_type| type_class.convert_from(value_type)}
      params       = params_class.new
      resource.params.each_pair{ |key, value| params[key.clone] = value.clone}
      option       = resource.option.clone
      self.new(id, input_types, output_types, params, option)
    end

    class Params < Hash
      def to_exp(indent)
        if self.size == 0 then
          return indent + "(PARAMS)"
        else
          return ([indent + "(PARAMS"] + self.to_a.map{|pair| indent + "  (#{pair[0]} #{pair[1]})"} + [indent + ")"]).join("")
        end
      end
    end
    
    class Set               < Iroha::IResource
      CLASS_NAME   = "set"
      IS_EXCLUSIVE = false
      def initialize(id, input_types, output_types, params, option)
        super(CLASS_NAME, IS_EXCLUSIVE, id, input_types, output_types, params, option)
      end
    end

    class Phi               < Iroha::IResource
      CLASS_NAME   = "phi"
      IS_EXCLUSIVE = false
      def initialize(id, input_types, output_types, params, option)
        super(CLASS_NAME, IS_EXCLUSIVE, id, input_types, output_types, params, option)
      end
    end

    class Select            < Iroha::IResource
      CLASS_NAME   = "select"
      IS_EXCLUSIVE = false
      def initialize(id, input_types, output_types, params, option)
        super(CLASS_NAME, IS_EXCLUSIVE, id, input_types, output_types, params, option)
      end
    end

    class Print             < Iroha::IResource
      CLASS_NAME   = "print"
      IS_EXCLUSIVE = false
      def initialize(id, input_types, output_types, params, option)
        super(CLASS_NAME, IS_EXCLUSIVE, id, input_types, output_types, params, option)
      end
    end

    class Assert            < Iroha::IResource
      CLASS_NAME   = "assert"
      IS_EXCLUSIVE = false
      def initialize(id, input_types, output_types, params, option)
        super(CLASS_NAME, IS_EXCLUSIVE, id, input_types, output_types, params, option)
      end
    end

    class Mapped            < Iroha::IResource
      CLASS_NAME   = "mapped"
      IS_EXCLUSIVE = true
      def initialize(id, input_types, output_types, params, option)
        super(CLASS_NAME, IS_EXCLUSIVE, id, input_types, output_types, params, option)
      end
    end

    class ChannelWrite      < Iroha::IResource
      CLASS_NAME   = "channel-write"
      IS_EXCLUSIVE = true
      def initialize(id, input_types, output_types, params, option)
        super(CLASS_NAME, IS_EXCLUSIVE, id, input_types, output_types, params, option)
      end
    end

    class ChannelRead       < Iroha::IResource
      CLASS_NAME   = "channel-read"
      IS_EXCLUSIVE = true
      def initialize(id, input_types, output_types, params, option)
        super(CLASS_NAME, IS_EXCLUSIVE, id, input_types, output_types, params, option)
      end
    end

    class SiblingTask       < Iroha::IResource
      CLASS_NAME   = "sibling-task"
      IS_EXCLUSIVE = true
      def initialize(id, input_types, output_types, params, option)
        super(CLASS_NAME, IS_EXCLUSIVE, id, input_types, output_types, params, option)
      end
    end

    class SiblingTaskCall   < Iroha::IResource
      CLASS_NAME   = "sibling-task-call"
      IS_EXCLUSIVE = true
      def initialize(id, input_types, output_types, params, option)
        super(CLASS_NAME, IS_EXCLUSIVE, id, input_types, output_types, params, option)
      end
    end

    class SubModuleTaskCall < Iroha::IResource
      CLASS_NAME   = "sub-module-task-call"
      IS_EXCLUSIVE = true
      def initialize(id, input_types, output_types, params, option)
        super(CLASS_NAME, IS_EXCLUSIVE, id, input_types, output_types, params, option)
      end
    end

    class SubModuleTask     < Iroha::IResource
      CLASS_NAME   = "sub-module-task"
      IS_EXCLUSIVE = true
      def initialize(id, input_types, output_types, params, option)
        super(CLASS_NAME, IS_EXCLUSIVE, id, input_types, output_types, params, option)
      end
    end

    class Transition        < Iroha::IResource
      CLASS_NAME   = "tr"
      IS_EXCLUSIVE = true
      def initialize(id, input_types, output_types, params, option)
        super(CLASS_NAME, IS_EXCLUSIVE, id, input_types, output_types, params, option)
      end
    end

    class Embedded          < Iroha::IResource
      CLASS_NAME   = "embedded"
      IS_EXCLUSIVE = true
      def initialize(id, input_types, output_types, params, option)
        super(CLASS_NAME, IS_EXCLUSIVE, id, input_types, output_types, params, option)
      end
    end

    class ForeignReg        < Iroha::IResource
      CLASS_NAME   = "foreign-reg"
      IS_EXCLUSIVE = true
      def initialize(id, input_types, output_types, params, option)
        super(CLASS_NAME, IS_EXCLUSIVE, id, input_types, output_types, params, option)
      end
    end

    class ExtInput          < Iroha::IResource
      CLASS_NAME   = "ext-input"
      IS_EXCLUSIVE = true
      def initialize(id, input_types, output_types, params, option)
        super(CLASS_NAME, IS_EXCLUSIVE, id, input_types, output_types, params, option)
      end
    end

    class ExtOutput         < Iroha::IResource
      CLASS_NAME   = "ext-output"
      IS_EXCLUSIVE = true
      def initialize(id, input_types, output_types, params, option)
        super(CLASS_NAME, IS_EXCLUSIVE, id, input_types, output_types, params, option)
      end
    end

    class Array            < Iroha::IResource
      CLASS_NAME   = "array"
      IS_EXCLUSIVE = true
      def initialize(id, input_types, output_types, params, option)
        super(CLASS_NAME, IS_EXCLUSIVE, id, input_types, output_types, params, option)
      end
    end

    class Gt                < Iroha::IResource
      CLASS_NAME   = "gt"
      IS_EXCLUSIVE = true
      def initialize(id, input_types, output_types, params, option)
        super(CLASS_NAME, IS_EXCLUSIVE, id, input_types, output_types, params, option)
      end
    end

    class Gte               < Iroha::IResource
      CLASS_NAME   = "gte"
      IS_EXCLUSIVE = true
      def initialize(id, input_types, output_types, params, option)
        super(CLASS_NAME, IS_EXCLUSIVE, id, input_types, output_types, params, option)
      end
    end

    class Eq                < Iroha::IResource
      CLASS_NAME   = "eq"
      IS_EXCLUSIVE = true
      def initialize(id, input_types, output_types, params, option)
        super(CLASS_NAME, IS_EXCLUSIVE, id, input_types, output_types, params, option)
      end
    end

    class Add               < Iroha::IResource
      CLASS_NAME   = "add"
      IS_EXCLUSIVE = true
      def initialize(id, input_types, output_types, params, option)
        super(CLASS_NAME, IS_EXCLUSIVE, id, input_types, output_types, params, option)
      end
    end

    class Sub               < Iroha::IResource
      CLASS_NAME   = "sub"
      IS_EXCLUSIVE = true
      def initialize(id, input_types, output_types, params, option)
        super(CLASS_NAME, IS_EXCLUSIVE, id, input_types, output_types, params, option)
      end
    end

    class Mul               < Iroha::IResource
      CLASS_NAME   = "mul"
      IS_EXCLUSIVE = true
      def initialize(id, input_types, output_types, params, option)
        super(CLASS_NAME, IS_EXCLUSIVE, id, input_types, output_types, params, option)
      end
    end

    class BitAnd            < Iroha::IResource
      CLASS_NAME   = "bit-and"
      IS_EXCLUSIVE = false
      def initialize(id, input_types, output_types, params, option)
        super(CLASS_NAME, IS_EXCLUSIVE, id, input_types, output_types, params, option)
      end
    end

    class BitOr             < Iroha::IResource
      CLASS_NAME   = "bit-or"
      IS_EXCLUSIVE = false
      def initialize(id, input_types, output_types, params, option)
        super(CLASS_NAME, IS_EXCLUSIVE, id, input_types, output_types, params, option)
      end
    end

    class BitXor            < Iroha::IResource
      CLASS_NAME   = "bit-xor"
      IS_EXCLUSIVE = false
      def initialize(id, input_types, output_types, params, option)
        super(CLASS_NAME, IS_EXCLUSIVE, id, input_types, output_types, params, option)
      end
    end

    class BitInv            < Iroha::IResource
      CLASS_NAME   = "bit-inv"
      IS_EXCLUSIVE = false
      def initialize(id, input_types, output_types, params, option)
        super(CLASS_NAME, IS_EXCLUSIVE, id, input_types, output_types, params, option)
      end
    end

    class Shift             < Iroha::IResource
      CLASS_NAME   = "shift"
      IS_EXCLUSIVE = false
      def initialize(id, input_types, output_types, params, option)
        super(CLASS_NAME, IS_EXCLUSIVE, id, input_types, output_types, params, option)
      end
    end

    class BitSel            < Iroha::IResource
      CLASS_NAME   = "bit-sel"
      IS_EXCLUSIVE = false
      def initialize(id, input_types, output_types, params, option)
        super(CLASS_NAME, IS_EXCLUSIVE, id, input_types, output_types, params, option)
      end
    end

    class BitConcat         < Iroha::IResource
      CLASS_NAME   = "bit-concat"
      IS_EXCLUSIVE = false
      def initialize(id, input_types, output_types, params, option)
        super(CLASS_NAME, IS_EXCLUSIVE, id, input_types, output_types, params, option)
      end
    end

  end

  STANDARD_RESOURSE_CLASSES = ObjectSpace.each_object(Class).select{|klass| klass.superclass == Iroha::IResource}
  
end
