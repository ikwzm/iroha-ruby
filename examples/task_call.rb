require_relative '../lib/iroha/builder/simple'

include Iroha::Builder::Simple

design = IDesign :design do
  IModule :mod do
    ITable :callee_tab do
      Register        :r_arg => Unsigned(32)
      SiblingTask     :task  , Unsigned(32)
      IState          :st10
      IState          :st11
      IState          :st12
      st10.on {
        task.entry(r_arg)
        Goto  st11
      }
      st11.on {
        Print r_arg
        Goto  st12
      }
    end
    ITable :caller_tab do
      SiblingTaskCall :task , Unsigned(32), _owner_design.mod.callee_tab.task
      IState          :st20
      IState          :st21
      IState          :st22
      st20.on {
        task.call(To_Unsigned(456,32))
        Goto st21
      }
      st21.on {
        task.wait
        Goto st22
      }
    end
  end
end

puts design.to_exp("")
