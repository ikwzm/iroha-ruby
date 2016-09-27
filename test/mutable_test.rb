require 'treetop'
require_relative '../lib/iroha.rb'
require_relative '../lib/iroha/builder/exp_parser.rb'
require_relative '../lib/iroha/iroha/modules/mutable.rb'

DEBUG=false

module MutableTest
  Iroha.franchise_class(Iroha,self)
  class  IDesign
    include Iroha::Modules::Mutable::IDesign
    def initialize
      super
      _add_new_initialize
    end
  end
  class  IModule
    include Iroha::Modules::Mutable::IModule
    def initialize(id, name, parent_id, params, table_list)
      super
      _add_new_initialize()
    end
  end
  class  ITable
    include Iroha::Modules::Mutable::ITable
    def initialize(id, name, resource_list, register_list, state_list, init_state_id)
      super
      _add_new_initialize()
    end
  end
  class  IRegister
    include Iroha::Modules::Mutable::IRegister
  end
  class  IState
    include Iroha::Modules::Mutable::IState
  end
  class  IInstruction
    include Iroha::Modules::Mutable::IInstruction
  end
  module Resource
    class Set
      include Iroha::Modules::Mutable::IResource
    end
    class Add
      include Iroha::Modules::Mutable::IResource
    end
    class Sub
      include Iroha::Modules::Mutable::IResource
    end
    class ChannelRead
      include Iroha::Modules::Mutable::IResource
    end
    class ChannelWrite
      include Iroha::Modules::Mutable::IResource
    end
  end
end

def test(title, design, expect)
  parser = Iroha::ExpParser.new
  result = parser.parse(expect)
  if !result then
    puts parser.failure_reason
    puts "!!!! NG !!!! #{title}"
    return 1
  end
  expect_exp = result.get.to_exp("")
  design_exp = design.to_exp("")
  o = design_exp.gsub(/\s+/, " ").gsub(/\s+\(/, " (").gsub(/\(\s*/, "(").gsub(/\s*\)/, ")").gsub(/\)\s*\(/, ") (").gsub(/\)\s*$/, ")")
  r = expect_exp.gsub(/\s+/, " ").gsub(/\s+\(/, " (").gsub(/\(\s*/, "(").gsub(/\s*\)/, ")").gsub(/\)\s*\(/, ") (").gsub(/\)\s*$/, ")")
  if o != r then
    puts ">>>>"
    puts o
    puts "<<<<"
    puts r
    puts "!!!! NG !!!! #{title}"
    return 1
  else
    puts r if DEBUG == true
    puts "==== OK ==== #{title}"
    return 0
  end
end

error = 0

design = MutableTest::IDesign.new
int32  = MutableTest::IValueType.new(true, 32)
int24  = MutableTest::IValueType.new(true, 24)
int16  = MutableTest::IValueType.new(true, 16)
int08  = MutableTest::IValueType.new(true,  8)

error += test("Test 1.1", design, "(PARAMS)")
design._add_new_module(MutableTest::IModule, :mod_1, nil, MutableTest::IParams.new, [])
error += test("Test 1.2", design, "(PARAMS)(MODULE 1 mod_1)")
design._add_new_module(MutableTest::IModule, :mod_2, nil, MutableTest::IParams.new, [])
error += test("Test 1.3", design, "(PARAMS)(MODULE 1 mod_1)(MODULE 2 mod_2)")
design._add_new_module(MutableTest::IModule, :mod_3, nil, MutableTest::IParams.new, [])
error += test("Test 1.4", design, "(PARAMS)(MODULE 1 mod_1)(MODULE 2 mod_2)(MODULE 3 mod_3)")
design._delete_module(design._find_module(2))
error += test("Test 1.5", design, "(PARAMS)(MODULE 1 mod_1)(MODULE 3 mod_3)")
design._add_new_module(MutableTest::IModule, :mod_4, nil, MutableTest::IParams.new, [])
error += test("Test 1.6", design, "(PARAMS)(MODULE 1 mod_1)(MODULE 3 mod_3)(MODULE 4 mod_4)")
design._reallocate_modules_id
error += test("Test 1.7", design, "(PARAMS)(MODULE 1 mod_1)(MODULE 2 mod_3)(MODULE 3 mod_4)")
design._add_new_module(MutableTest::IModule, :mod_5, nil, MutableTest::IParams.new, [])
error += test("Test 1.8", design, "(PARAMS)(MODULE 1 mod_1)(MODULE 2 mod_3)(MODULE 3 mod_4)(MODULE 4 mod_5)")
design._delete_module(design._find_module(1))
design._delete_module(design._find_module(3))
design._delete_module(design._find_module(4))
design._reallocate_modules_id
error += test("Test 1.9", design, "(PARAMS)(MODULE 1 mod_3)")

mod = design._find_module(1)
mod._add_new_table(MutableTest::ITable, nil, [], [], [], nil)
error += test("Test 2.1", design, "(PARAMS)(MODULE 1 mod_3 (PARAMS)(TABLE 1 (REGISTERS)(RESOURCES)))")
mod._add_new_table(MutableTest::ITable, nil, [], [], [], nil)
error += test("Test 2.2", design, "(PARAMS)(MODULE 1 mod_3 (PARAMS)(TABLE 1 (REGISTERS)(RESOURCES))(TABLE 2 (REGISTERS)(RESOURCES)))")
mod._add_new_table(MutableTest::ITable, nil, [], [], [], nil)
error += test("Test 2.3", design, "(PARAMS)(MODULE 1 mod_3 (PARAMS)(TABLE 1 (REGISTERS)(RESOURCES))(TABLE 2 (REGISTERS)(RESOURCES))(TABLE 3 (REGISTERS)(RESOURCES)))")
mod._delete_table(mod._find_table(1))
mod._delete_table(mod._find_table(2))
error += test("Test 2.4", design, "(PARAMS)(MODULE 1 mod_3 (PARAMS)(TABLE 3 (REGISTERS)(RESOURCES)))")
mod._add_new_table(MutableTest::ITable, nil, [], [], [], nil)
error += test("Test 2.5", design, "(PARAMS)(MODULE 1 mod_3 (PARAMS)(TABLE 3 (REGISTERS)(RESOURCES))(TABLE 4 (REGISTERS)(RESOURCES)))")
mod._reallocate_tables_id
error += test("Test 2.6", design, "(PARAMS)(MODULE 1 mod_3 (PARAMS)(TABLE 1 (REGISTERS)(RESOURCES))(TABLE 2 (REGISTERS)(RESOURCES)))")
mod._delete_table(mod._find_table(1))
error += test("Test 2.7", design, "(PARAMS)(MODULE 1 mod_3 (PARAMS)(TABLE 2 (REGISTERS)(RESOURCES)))")
mod._reallocate_tables_id
error += test("Test 2.8", design, "(PARAMS)(MODULE 1 mod_3 (PARAMS)(TABLE 1 (REGISTERS)(RESOURCES)))")

tab = mod._find_table(1)
tab._add_new_register(MutableTest::IRegister, :reg_1, :REG  , int32, nil)
error += test("Test 3.1", design, "(PARAMS)(MODULE 1 mod_3 (PARAMS)(TABLE 1 
(REGISTERS 
  (REGISTER 1 reg_1 REG (INT 32) ())
)
(RESOURCES)))")
tab._add_new_register(MutableTest::IRegister, :reg_2, :WIRE , int16, nil)
error += test("Test 3.2", design, "(PARAMS)(MODULE 1 mod_3 (PARAMS)(TABLE 1 
(REGISTERS 
  (REGISTER 1 reg_1 REG  (INT 32) ())
  (REGISTER 2 reg_2 WIRE (INT 16) ())
)
(RESOURCES)))")
tab._add_new_register(MutableTest::IRegister, :reg_3, :CONST, int08, 8)
error += test("Test 3.3", design, "(PARAMS)(MODULE 1 mod_3 (PARAMS)(TABLE 1 
(REGISTERS 
  (REGISTER 1 reg_1 REG   (INT 32) ())
  (REGISTER 2 reg_2 WIRE  (INT 16) ())
  (REGISTER 3 reg_3 CONST (INT 8)   8)
)
(RESOURCES)))")
tab._delete_register(tab._find_register(2))
error += test("Test 3.4", design, "(PARAMS)(MODULE 1 mod_3 (PARAMS)(TABLE 1 
(REGISTERS 
  (REGISTER 1 reg_1 REG   (INT 32) ())
  (REGISTER 3 reg_3 CONST (INT 8)  8)
)
(RESOURCES)))")
tab._add_new_register(MutableTest::IRegister, :reg_2, :WIRE , int24, nil)
error += test("Test 3.5", design, "(PARAMS)(MODULE 1 mod_3 (PARAMS)(TABLE 1 
(REGISTERS 
  (REGISTER 1 reg_1 REG   (INT 32) ())
  (REGISTER 3 reg_3 CONST (INT 8)   8)
  (REGISTER 4 reg_2 WIRE  (INT 24) ())
)
(RESOURCES)))")
tab._reallocate_registers_id
error += test("Test 3.6", design, "(PARAMS)(MODULE 1 mod_3 (PARAMS)(TABLE 1 
(REGISTERS 
  (REGISTER 1 reg_1 REG   (INT 32) ())
  (REGISTER 2 reg_3 CONST (INT  8)  8)
  (REGISTER 3 reg_2 WIRE  (INT 24) ())
)
(RESOURCES)))")
tab._delete_register(tab._find_register(1))
error += test("Test 3.7", design, "(PARAMS)(MODULE 1 mod_3 (PARAMS)(TABLE 1 
(REGISTERS 
  (REGISTER 2 reg_3 CONST (INT  8)  8)
  (REGISTER 3 reg_2 WIRE  (INT 24) ())
)
(RESOURCES)))")
tab._add_new_register(MutableTest::IRegister, :reg_1, :REG  , int32, nil)
error += test("Test 3.8", design, "(PARAMS)(MODULE 1 mod_3 (PARAMS)(TABLE 1 
(REGISTERS 
  (REGISTER 2 reg_3 CONST (INT  8)  8)
  (REGISTER 3 reg_2 WIRE  (INT 24) ())
  (REGISTER 4 reg_1 REG   (INT 32) ())
)
(RESOURCES)))")
tab._delete_register(tab._find_register(2))
tab._delete_register(tab._find_register(3))
tab._reallocate_registers_id
tab._add_new_register(MutableTest::IRegister, :reg_2, :REG  , int24, nil)
tab._add_new_register(MutableTest::IRegister, :reg_3, :REG  , int16, nil)
error += test("Test 3.9", design, "(PARAMS)(MODULE 1 mod_3 (PARAMS)(TABLE 1 
(REGISTERS 
  (REGISTER 1 reg_1 REG (INT 32) ())
  (REGISTER 2 reg_2 REG (INT 24) ())
  (REGISTER 3 reg_3 REG (INT 16) ())
)
(RESOURCES)))")

tab._add_new_resource(MutableTest::Resource::Set, [int32], [int32], MutableTest::IParams.new, {})
tab._add_new_resource(MutableTest::Resource::Set, [int32], [int32], MutableTest::IParams.new, {})
tab._add_new_resource(MutableTest::Resource::ChannelWrite, [], [int32], MutableTest::IParams.new, {})
tab._find_resource(3)._immutable = true
error += test("Test 4.1", design, "(PARAMS)(MODULE 1 mod_3 (PARAMS)(TABLE 1
(REGISTERS 
  (REGISTER 1 reg_1 REG (INT 32) ())
  (REGISTER 2 reg_2 REG (INT 24) ())
  (REGISTER 3 reg_3 REG (INT 16) ())
)
(RESOURCES 
  (RESOURCE 1 set ((INT 32)) ((INT 32)) (PARAMS))
  (RESOURCE 2 set ((INT 32)) ((INT 32)) (PARAMS))
  (RESOURCE 3 channel-write () ((INT 32)) (PARAMS))
)))")
tab._add_new_resource(MutableTest::Resource::ChannelRead , [int32], [], MutableTest::IParams.new, {})
tab._find_resource(4)._immutable = true
error += test("Test 4.2", design, "(PARAMS)(MODULE 1 mod_3 (PARAMS)(TABLE 1
(REGISTERS 
  (REGISTER 1 reg_1 REG (INT 32) ())
  (REGISTER 2 reg_2 REG (INT 24) ())
  (REGISTER 3 reg_3 REG (INT 16) ())
)
(RESOURCES 
  (RESOURCE 1 set ((INT 32)) ((INT 32)) (PARAMS))
  (RESOURCE 2 set ((INT 32)) ((INT 32)) (PARAMS))
  (RESOURCE 3 channel-write () ((INT 32)) (PARAMS))
  (RESOURCE 4 channel-read  ((INT 32)) () (PARAMS))
)))")
tab._delete_resource(tab._find_resource(1))
error += test("Test 4.3", design, "(PARAMS)(MODULE 1 mod_3 (PARAMS)(TABLE 1
(REGISTERS 
  (REGISTER 1 reg_1 REG (INT 32) ())
  (REGISTER 2 reg_2 REG (INT 24) ())
  (REGISTER 3 reg_3 REG (INT 16) ())
)
(RESOURCES 
  (RESOURCE 2 set ((INT 32)) ((INT 32)) (PARAMS))
  (RESOURCE 3 channel-write () ((INT 32)) (PARAMS))
  (RESOURCE 4 channel-read  ((INT 32)) () (PARAMS))
)))")
tab._add_new_resource(MutableTest::Resource::Add, [int32,int32], [int32], MutableTest::IParams.new, {})
error += test("Test 4.4", design, "(PARAMS)(MODULE 1 mod_3 (PARAMS)(TABLE 1
(REGISTERS 
  (REGISTER 1 reg_1 REG (INT 32) ())
  (REGISTER 2 reg_2 REG (INT 24) ())
  (REGISTER 3 reg_3 REG (INT 16) ())
)
(RESOURCES 
  (RESOURCE 2 set ((INT 32)) ((INT 32)) (PARAMS))
  (RESOURCE 3 channel-write () ((INT 32)) (PARAMS))
  (RESOURCE 4 channel-read  ((INT 32)) () (PARAMS))
  (RESOURCE 5 add  ((INT 32)(INT 32)) ((INT 32)) (PARAMS))
)))")
tab._delete_resource(tab._find_resource(2))
tab._add_new_resource(MutableTest::Resource::Sub, [int32,int32], [int32], MutableTest::IParams.new, {})
error += test("Test 4.5", design, "(PARAMS)(MODULE 1 mod_3 (PARAMS)(TABLE 1
(REGISTERS 
  (REGISTER 1 reg_1 REG (INT 32) ())
  (REGISTER 2 reg_2 REG (INT 24) ())
  (REGISTER 3 reg_3 REG (INT 16) ())
)
(RESOURCES 
  (RESOURCE 3 channel-write () ((INT 32)) (PARAMS))
  (RESOURCE 4 channel-read  ((INT 32)) () (PARAMS))
  (RESOURCE 5 add  ((INT 32)(INT 32)) ((INT 32)) (PARAMS))
  (RESOURCE 6 sub  ((INT 32)(INT 32)) ((INT 32)) (PARAMS))
)))")
tab._reallocate_resources_id
error += test("Test 4.6", design, "(PARAMS)(MODULE 1 mod_3 (PARAMS)(TABLE 1
(REGISTERS 
  (REGISTER 1 reg_1 REG (INT 32) ())
  (REGISTER 2 reg_2 REG (INT 24) ())
  (REGISTER 3 reg_3 REG (INT 16) ())
)
(RESOURCES 
  (RESOURCE 3 channel-write () ((INT 32)) (PARAMS))
  (RESOURCE 4 channel-read  ((INT 32)) () (PARAMS))
  (RESOURCE 1 add  ((INT 32)(INT 32)) ((INT 32)) (PARAMS))
  (RESOURCE 2 sub  ((INT 32)(INT 32)) ((INT 32)) (PARAMS))
)))")

tab._add_new_register(MutableTest::IRegister, :reg_4, :REG  , int32, nil)
tab._add_new_register(MutableTest::IRegister, :reg_5, :REG  , int32, nil)
tab._add_new_resource(MutableTest::Resource::Set, [int32], [int32], MutableTest::IParams.new, {})
tab._add_new_state(MutableTest::IState, :state_1, [])
tab._add_new_state(MutableTest::IState, :state_2, [])
tab._add_new_state(MutableTest::IState, :state_3, [])
tab._init_state_id = 1
st1 = tab._states[1]
st2 = tab._states[2]
st1._add_new_instruction(MutableTest::IInstruction, :add, 1, [], [], [4,5],[1])
st1._add_new_instruction(MutableTest::IInstruction, :sub, 2, [], [], [4,5],[1])
st2._add_new_instruction(MutableTest::IInstruction, :set, 5, [], [], [1],[4])
error += test("Test 5.1", design, "(PARAMS)(MODULE 1 mod_3 (PARAMS)(TABLE 1
(REGISTERS 
  (REGISTER 1 reg_1 REG (INT 32) ())
  (REGISTER 2 reg_2 REG (INT 24) ())
  (REGISTER 3 reg_3 REG (INT 16) ())
  (REGISTER 4 reg_4 REG (INT 32) ())
  (REGISTER 5 reg_5 REG (INT 32) ())
)
(RESOURCES 
  (RESOURCE 3 channel-write () ((INT 32)) (PARAMS))
  (RESOURCE 4 channel-read  ((INT 32)) () (PARAMS))
  (RESOURCE 1 add  ((INT 32)(INT 32)) ((INT 32)) (PARAMS))
  (RESOURCE 2 sub  ((INT 32)(INT 32)) ((INT 32)) (PARAMS))
  (RESOURCE 5 set  ((INT 32)) ((INT 32)) (PARAMS))
)
(INITIAL 1)
(STATE 1
  (INSN 1 add 1 () () (4 5) (1))
  (INSN 2 sub 2 () () (4 5) (1))
)
(STATE 2
  (INSN 3 set 5 () () (1) (4))
)
(STATE 3)
))")
tab._delete_state(tab._states[2])
error += test("Test 5.2", design, "(PARAMS)(MODULE 1 mod_3 (PARAMS)(TABLE 1
(REGISTERS 
  (REGISTER 1 reg_1 REG (INT 32) ())
  (REGISTER 2 reg_2 REG (INT 24) ())
  (REGISTER 3 reg_3 REG (INT 16) ())
  (REGISTER 4 reg_4 REG (INT 32) ())
  (REGISTER 5 reg_5 REG (INT 32) ())
)
(RESOURCES 
  (RESOURCE 3 channel-write () ((INT 32)) (PARAMS))
  (RESOURCE 4 channel-read  ((INT 32)) () (PARAMS))
  (RESOURCE 1 add  ((INT 32)(INT 32)) ((INT 32)) (PARAMS))
  (RESOURCE 2 sub  ((INT 32)(INT 32)) ((INT 32)) (PARAMS))
  (RESOURCE 5 set  ((INT 32)) ((INT 32)) (PARAMS))
)
(INITIAL 1)
(STATE 1
  (INSN 1 add 1 () () (4 5) (1))
  (INSN 2 sub 2 () () (4 5) (1))
)
(STATE 3)
))")
tab._add_new_state(MutableTest::IState, :state_4, [])
error += test("Test 5.3", design, "(PARAMS)(MODULE 1 mod_3 (PARAMS)(TABLE 1
(REGISTERS 
  (REGISTER 1 reg_1 REG (INT 32) ())
  (REGISTER 2 reg_2 REG (INT 24) ())
  (REGISTER 3 reg_3 REG (INT 16) ())
  (REGISTER 4 reg_4 REG (INT 32) ())
  (REGISTER 5 reg_5 REG (INT 32) ())
)
(RESOURCES 
  (RESOURCE 3 channel-write () ((INT 32)) (PARAMS))
  (RESOURCE 4 channel-read  ((INT 32)) () (PARAMS))
  (RESOURCE 1 add  ((INT 32)(INT 32)) ((INT 32)) (PARAMS))
  (RESOURCE 2 sub  ((INT 32)(INT 32)) ((INT 32)) (PARAMS))
  (RESOURCE 5 set  ((INT 32)) ((INT 32)) (PARAMS))
)
(INITIAL 1)
(STATE 1
  (INSN 1 add 1 () () (4 5) (1))
  (INSN 2 sub 2 () () (4 5) (1))
)
(STATE 3)
(STATE 4)
))")
tab._reallocate_states_id
st2 = tab._states[2]
st2._add_new_instruction(MutableTest::IInstruction, :set, 5, [], [], [4],[1])
error += test("Test 5.4", design, "(PARAMS)(MODULE 1 mod_3 (PARAMS)(TABLE 1
(REGISTERS 
  (REGISTER 1 reg_1 REG (INT 32) ())
  (REGISTER 2 reg_2 REG (INT 24) ())
  (REGISTER 3 reg_3 REG (INT 16) ())
  (REGISTER 4 reg_4 REG (INT 32) ())
  (REGISTER 5 reg_5 REG (INT 32) ())
)
(RESOURCES 
  (RESOURCE 3 channel-write () ((INT 32)) (PARAMS))
  (RESOURCE 4 channel-read  ((INT 32)) () (PARAMS))
  (RESOURCE 1 add  ((INT 32)(INT 32)) ((INT 32)) (PARAMS))
  (RESOURCE 2 sub  ((INT 32)(INT 32)) ((INT 32)) (PARAMS))
  (RESOURCE 5 set  ((INT 32)) ((INT 32)) (PARAMS))
)
(INITIAL 1)
(STATE 1
  (INSN 1 add 1 () () (4 5) (1))
  (INSN 2 sub 2 () () (4 5) (1))
)
(STATE 2
  (INSN 4 set 5 () () (4) (1))
)
(STATE 3)
))")
tab._reallocate_instructions_id
error += test("Test 5.5", design, "(PARAMS)(MODULE 1 mod_3 (PARAMS)(TABLE 1
(REGISTERS 
  (REGISTER 1 reg_1 REG (INT 32) ())
  (REGISTER 2 reg_2 REG (INT 24) ())
  (REGISTER 3 reg_3 REG (INT 16) ())
  (REGISTER 4 reg_4 REG (INT 32) ())
  (REGISTER 5 reg_5 REG (INT 32) ())
)
(RESOURCES 
  (RESOURCE 3 channel-write () ((INT 32)) (PARAMS))
  (RESOURCE 4 channel-read  ((INT 32)) () (PARAMS))
  (RESOURCE 1 add  ((INT 32)(INT 32)) ((INT 32)) (PARAMS))
  (RESOURCE 2 sub  ((INT 32)(INT 32)) ((INT 32)) (PARAMS))
  (RESOURCE 5 set  ((INT 32)) ((INT 32)) (PARAMS))
)
(INITIAL 1)
(STATE 1
  (INSN 1 add 1 () () (4 5) (1))
  (INSN 2 sub 2 () () (4 5) (1))
)
(STATE 2
  (INSN 3 set 5 () () (4) (1))
)
(STATE 3)
))")
st1._delete_instruction(st1._instructions[2])
error += test("Test 5.6", design, "(PARAMS)(MODULE 1 mod_3 (PARAMS)(TABLE 1
(REGISTERS 
  (REGISTER 1 reg_1 REG (INT 32) ())
  (REGISTER 2 reg_2 REG (INT 24) ())
  (REGISTER 3 reg_3 REG (INT 16) ())
  (REGISTER 4 reg_4 REG (INT 32) ())
  (REGISTER 5 reg_5 REG (INT 32) ())
)
(RESOURCES 
  (RESOURCE 3 channel-write () ((INT 32)) (PARAMS))
  (RESOURCE 4 channel-read  ((INT 32)) () (PARAMS))
  (RESOURCE 1 add  ((INT 32)(INT 32)) ((INT 32)) (PARAMS))
  (RESOURCE 2 sub  ((INT 32)(INT 32)) ((INT 32)) (PARAMS))
  (RESOURCE 5 set  ((INT 32)) ((INT 32)) (PARAMS))
)
(INITIAL 1)
(STATE 1
  (INSN 1 add 1 () () (4 5) (1))
)
(STATE 2
  (INSN 3 set 5 () () (4) (1))
)
(STATE 3)
))")
st2._add_new_instruction(MutableTest::IInstruction, :set, 5, [], [], [1],[4])
error += test("Test 5.7", design, "(PARAMS)(MODULE 1 mod_3 (PARAMS)(TABLE 1
(REGISTERS 
  (REGISTER 1 reg_1 REG (INT 32) ())
  (REGISTER 2 reg_2 REG (INT 24) ())
  (REGISTER 3 reg_3 REG (INT 16) ())
  (REGISTER 4 reg_4 REG (INT 32) ())
  (REGISTER 5 reg_5 REG (INT 32) ())
)
(RESOURCES 
  (RESOURCE 3 channel-write () ((INT 32)) (PARAMS))
  (RESOURCE 4 channel-read  ((INT 32)) () (PARAMS))
  (RESOURCE 1 add  ((INT 32)(INT 32)) ((INT 32)) (PARAMS))
  (RESOURCE 2 sub  ((INT 32)(INT 32)) ((INT 32)) (PARAMS))
  (RESOURCE 5 set  ((INT 32)) ((INT 32)) (PARAMS))
)
(INITIAL 1)
(STATE 1
  (INSN 1 add 1 () () (4 5) (1))
)
(STATE 2
  (INSN 3 set 5 () () (4) (1))
  (INSN 4 set 5 () () (1) (4))
)
(STATE 3)
))")

tab._reallocate_instructions_id
error += test("Test 5.8", design, "(PARAMS)(MODULE 1 mod_3 (PARAMS)(TABLE 1
(REGISTERS 
  (REGISTER 1 reg_1 REG (INT 32) ())
  (REGISTER 2 reg_2 REG (INT 24) ())
  (REGISTER 3 reg_3 REG (INT 16) ())
  (REGISTER 4 reg_4 REG (INT 32) ())
  (REGISTER 5 reg_5 REG (INT 32) ())
)
(RESOURCES 
  (RESOURCE 3 channel-write () ((INT 32)) (PARAMS))
  (RESOURCE 4 channel-read  ((INT 32)) () (PARAMS))
  (RESOURCE 1 add  ((INT 32)(INT 32)) ((INT 32)) (PARAMS))
  (RESOURCE 2 sub  ((INT 32)(INT 32)) ((INT 32)) (PARAMS))
  (RESOURCE 5 set  ((INT 32)) ((INT 32)) (PARAMS))
)
(INITIAL 1)
(STATE 1
  (INSN 1 add 1 () () (4 5) (1))
)
(STATE 2
  (INSN 2 set 5 () () (4) (1))
  (INSN 3 set 5 () () (1) (4))
)
(STATE 3)
))")
tab._delete_register(tab._find_register(2))
tab._delete_register(tab._find_register(3))
tab._reallocate_registers_id
error += test("Test 6.1", design, "(PARAMS)(MODULE 1 mod_3 (PARAMS)(TABLE 1
(REGISTERS 
  (REGISTER 1 reg_1 REG (INT 32) ())
  (REGISTER 2 reg_4 REG (INT 32) ())
  (REGISTER 3 reg_5 REG (INT 32) ())
)
(RESOURCES 
  (RESOURCE 3 channel-write () ((INT 32)) (PARAMS))
  (RESOURCE 4 channel-read  ((INT 32)) () (PARAMS))
  (RESOURCE 1 add  ((INT 32)(INT 32)) ((INT 32)) (PARAMS))
  (RESOURCE 2 sub  ((INT 32)(INT 32)) ((INT 32)) (PARAMS))
  (RESOURCE 5 set  ((INT 32)) ((INT 32)) (PARAMS))
)
(INITIAL 1)
(STATE 1
  (INSN 1 add 1 () () (2 3) (1))
)
(STATE 2
  (INSN 2 set 5 () () (2) (1))
  (INSN 3 set 5 () () (1) (2))
)
(STATE 3)
))")
tab._delete_resource(tab._find_resource(2))
tab._reallocate_resources_id
error += test("Test 6.2", design, "(PARAMS)(MODULE 1 mod_3 (PARAMS)(TABLE 1
(REGISTERS 
  (REGISTER 1 reg_1 REG (INT 32) ())
  (REGISTER 2 reg_4 REG (INT 32) ())
  (REGISTER 3 reg_5 REG (INT 32) ())
)
(RESOURCES 
  (RESOURCE 3 channel-write () ((INT 32)) (PARAMS))
  (RESOURCE 4 channel-read  ((INT 32)) () (PARAMS))
  (RESOURCE 1 add  ((INT 32)(INT 32)) ((INT 32)) (PARAMS))
  (RESOURCE 2 set  ((INT 32)) ((INT 32)) (PARAMS))
)
(INITIAL 1)
(STATE 1
  (INSN 1 add 1 () () (2 3) (1))
)
(STATE 2
  (INSN 2 set 2 () () (2) (1))
  (INSN 3 set 2 () () (1) (2))
)
(STATE 3)
))")
tab._delete_resource(tab._find_resource(2))
tab._reallocate_resources_id

# design._add_new_channel(MutableTest::IChannel, MutableTest::IValueType.new(true,32), 1, 1, 1, 1, 1, 2)
# error += test("Test 2.1", design, "(PARAMS)(CHANNEL (INT 32) 1 1 1 1 1 2)(MODULE 1 mod_3)")
