require_relative '../lib/iroha/builder/simple'

include Iroha::Builder::Simple

design = IDesign :design do
  IModule :mod do
    ITable :tab_1 do
      CurrentState :curr_state
      IState       :st11
    end
    ITable :tab_2 do
      Wire         :curr_state_i, StateType(@_owner_design.mod.tab_1)
      PortInput    :curr_state  , StateType(@_owner_design.mod.tab_1)
      IState       :st21
      st21.on {
        curr_state_i <= curr_state
      }
    end
    tab_2.curr_state <= tab_1.curr_state
  end
end

puts design.to_exp("")
