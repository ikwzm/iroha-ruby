module Iroha

  class IResource
    attr_reader :_class_name, :_is_exclusive
    attr_reader :_id, :_input_types, :_output_types, :_params, :_option
    attr_reader :_owner_design, :_owner_module, :_owner_table
    
    def initialize(class_name, is_exclusive, id, input_types, output_types, params, option)
      @_class_name   = class_name      ## TYPE: string
      @_is_exclusive = is_exclusive    ## TYPE: boolean
      @_id           = id              ## TYPE: id
      @_input_types  = input_types     ## TYPE: Array[Iroha::IValueType]
      @_output_types = output_types    ## TYPE: Array[Iroha::IValueType]
      @_params       = params          ## TYPE: Iroha::IResource::Params
      @_option       = Hash.new;       ## Type: Hash {name:string, value:string or number}
      @_owner_design = nil
      @_owner_module = nil
      @_owner_table  = nil
      return if option == nil
      return if option.class == Hash and option.size == 0
      fail "(RESOURCE #{class_name} #{id} ... #{option}) is invalid option."
    end

    def _set_owner(owner_design, owner_module, owner_table)
      @_owner_design = owner_design
      @_owner_module = owner_module
      @_owner_table  = owner_table
    end

    def _set_owner_table(owner_table)
      @_owner_table  = owner_table
    end

    def _to_exp(indent)
      if self.class.method_defined?(:_option_to_exp) then
        option_exp = _option_to_exp()
      else
        option_exp = ""
      end
      return indent + "(RESOURCE #{@_id} #{@_class_name} " +
             "(" + @_input_types.map{ |t|t._to_exp}.join(" ") + ") " +
             "(" + @_output_types.map{|t|t._to_exp}.join(" ") + ") " +
             @_params._to_exp("") + option_exp + ")"
    end

    def _option_clone
      return Hash.new
    end

    def self.convert_from(resource)
      class_name   = resource.class.to_s.split(/::/).last
      parent_class = Iroha.parent_class(Iroha.parent_class(self))
      params_class = parent_class.const_get(:IResource).const_get(:Params)
      type_class   = parent_class.const_get(:IValueType)
      id           = resource._id
      input_types  = resource._input_types.map{ |value_type| type_class.convert_from(value_type)}
      output_types = resource._output_types.map{|value_type| type_class.convert_from(value_type)}
      params       = params_class.convert_from(resource._params)
      option       = resource._option_clone
      parent_class.const_get(:IResource).const_get(class_name).new(id, input_types, output_types, params, option)
    end

    def _id_to_str
      if @_owner_table != nil
        table_str = @_owner_table._id_to_str
      else
        table_str = "UnknownTable"
      end
      return table_str + "::IResource(#{@_class_name})[#{@_id}]"
    end

    class Params < Hash
      def _to_exp(indent)
        if self.size == 0 then
          return indent + "(PARAMS)"
        else
          return ([indent + "(PARAMS"] + self.to_a.map{|pair| indent + "  (#{pair[0]} #{pair[1]})"} + [indent + ")"]).join("")
        end
      end
      def self.convert_from(params)
        new_params = self.new
        params.each_pair do |key, value|
          if value.class == String then
            new_params[key] = value.clone
          else
            new_params[key] = value
          end
        end
        return new_params
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
        if option.key?(:"CALLEE-TABLE") then
          super(CLASS_NAME, IS_EXCLUSIVE, id, input_types, output_types, params, nil)
          @_callee_table_id = option[:"CALLEE-TABLE"]
        else
          super(CLASS_NAME, IS_EXCLUSIVE, id, input_types, output_types, params, option)
        end
      end
      def _option_clone
        if @_callee_table_id.class == Hash then
          return {:"CALLEE-TABLE" => @_callee_table_id.clone}
        else
          return {:"CALLEE-TABLE" => nil}
        end
      end
      def _option_to_exp
        table = _get_callee_table()
        fail "Not Found Callee Table in #{_id_to_str}" if table == nil
        return "(CALLEE-TABLE #{table._owner_module._id} #{table._id})"
      end
      def _get_callee_table
        if @_callee_table_id.class == Hash then
          return @_owner_design._find_table(@_callee_table_id[:MODULE], @_callee_table_id[:TABLE])
        else
          return nil
        end
      end
    end

    class SubModuleTaskCall < Iroha::IResource
      CLASS_NAME   = "sub-module-task-call"
      IS_EXCLUSIVE = true
      def initialize(id, input_types, output_types, params, option)
        if option.key?(:"CALLEE-TABLE") then
          super(CLASS_NAME, IS_EXCLUSIVE, id, input_types, output_types, params, nil)
          @_callee_table_id = option[:"CALLEE-TABLE"]
        else
          super(CLASS_NAME, IS_EXCLUSIVE, id, input_types, output_types, params, option)
        end
      end
      def _option_clone
        if @_callee_table_id.class == Hash then
          return {:"CALLEE-TABLE" => @_callee_table_id.clone}
        else
          return {:"CALLEE-TABLE" => nil}
        end
      end
      def _option_to_exp
        table = _get_callee_table()
        fail "Not Found Callee Table in #{_id_to_str}" if table == nil
        return "(CALLEE-TABLE #{table._owner_module._id} #{table._id})"
      end
      def _get_callee_table
        if @_callee_table_id.class == Hash then
          return @_owner_design._find_table(@_callee_table_id[:MODULE], @_callee_table_id[:TABLE])
        else
          return nil
        end
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
        if option.key?(:"FOREIGN-REG") then
          super(CLASS_NAME, IS_EXCLUSIVE, id, input_types, output_types, params, nil)
          @_foreign_register_id = option[:"FOREIGN-REG"]
        else
          super(CLASS_NAME, IS_EXCLUSIVE, id, input_types, output_types, params, option)
        end
      end
      def _option_clone
        if @_foreign_register_id.class == Hash then
          return {:"FOREIGN-REG" => @_foreign_register_id.clone}
        else
          return {:"FOREIGN-REG" => nil}
        end
      end
      def _option_to_exp
        register = _get_foreign_register()
        fail "Not Found Register(#{@_foreign_register_id}) in #{_id_to_str}" if nil == register
        return "(FOREIGN-REG #{register._owner_module._id} #{register._owner_table._id} #{register._id})"
      end
      def _get_foreign_register
        if @_foreign_register_id.class == Hash then
          mod_id = @_foreign_register_id[:MODULE  ]
          tab_id = @_foreign_register_id[:TABLE   ]
          reg_id = @_foreign_register_id[:REGISTER]
          return @_owner_design._find_register(mod_id, tab_id, reg_id)
        else
          return nil
        end
      end
    end

    class PortInput         < Iroha::IResource
      attr_accessor :_connections
      CLASS_NAME   = "port-input"
      OPTION_NAME  = "PORT-INPUT".to_sym
      IS_EXCLUSIVE = true
      def initialize(id, input_types, output_types, params, option)
        if option.key?(OPTION_NAME) then
          super(CLASS_NAME, IS_EXCLUSIVE, id, input_types, output_types, params, nil)
          @_connections = option[OPTION_NAME].fetch(:CONNECT, [])
        else
          super(CLASS_NAME, IS_EXCLUSIVE, id, input_types, output_types, params, option)
        end
      end
      def _option_clone
        return {OPTION_NAME => {:CONNECT => @_connections.map{|conn| conn.clone}}}
      end
      def _option_to_exp
        connections_exp = @_connections.map{|conn|
          resource = @_owner_design._find_resource(conn[:MODULE], conn[:TABLE], conn[:RESOURCE])
          if resource == nil then
            fail "Not found #{CLASS_NAME} resource(#{conn}) in #{_id_to_str}"
          end
          "(CONNECT #{resource._owner_module._id} #{resource._owner_table._id} #{resource._id})"
        }.join(" ")
        return "(#{OPTION_NAME} #{connections_exp})"
      end
    end

    class PortOutput        < Iroha::IResource
      attr_accessor :_connections
      CLASS_NAME   = "port-output"
      OPTION_NAME  = "PORT-OUTPUT".to_sym
      IS_EXCLUSIVE = true
      def initialize(id, input_types, output_types, params, option)
        if option.key?(OPTION_NAME) then
          super(CLASS_NAME, IS_EXCLUSIVE, id, input_types, output_types, params, nil)
          @_connections = option[OPTION_NAME].fetch(:CONNECT, [])
        else
          super(CLASS_NAME, IS_EXCLUSIVE, id, input_types, output_types, params, option)
        end
      end
      def _option_clone
        return {OPTION_NAME => {:CONNECT => @_connections.map{|conn| conn.clone}}}
      end
      def _option_to_exp
        connections_exp = @_connections.map{|conn|
          resource = @_owner_design._find_resource(conn[:MODULE], conn[:TABLE], conn[:RESOURCE])
          if resource == nil then
            fail "Not found #{CLASS_NAME} resource(#{conn}) in #{_id_to_str}"
          end
          "(CONNECT #{resource._owner_module._id} #{resource._owner_table._id} #{resource._id})"
        }.join(" ")
        return "(#{OPTION_NAME} #{connections_exp})"
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
        if option.key?(:ARRAY) then
          super(CLASS_NAME, IS_EXCLUSIVE, id, input_types, output_types, params, nil)
          @_addr_width  = option[:ARRAY][:ADDR_WIDTH]
          @_value_type  = option[:ARRAY][:VALUE_TYPE]
          @_is_external = option[:ARRAY][:EXTERNAL  ]
          @_is_ram      = option[:ARRAY][:RAM       ]
        else
          super(CLASS_NAME, IS_EXCLUSIVE, id, input_types, output_types, params, option)
        end
      end
      def _option_clone
        return {:ARRAY => {:ADDR_WIDTH => @_addr_width, :VALUE_TYPE => @_value_type, :EXTERNAL => @_is_external, :RAM => @_is_ram}}
      end
      def _option_to_exp
        external = (@_is_external == true) ? "EXTERNAL" : "INTERNAL"
        ram      = (@_is_ram      == true) ? "RAM"      : "ROM"
        return "(ARRAY #{@_addr_width} #{@_value_type._to_exp} #{external} #{ram})"
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
