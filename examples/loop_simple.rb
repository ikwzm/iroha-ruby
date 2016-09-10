require_relative '../lib/iroha/builder/simple'

include Iroha::Builder::Simple

design = IDesign :design do
  IModule :add do
    ITable :table do
      data_width = 32
      loop_size  = 10
      Register  :counter  , Unsigned(data_width)
      Register  :cond     , Unsigned( 0)

      IState    :state1
      IState    :state2
      IState    :state3
      IState    :state4
      IState    :state5

      state1.on {
        cond     <= (counter > To_Unsigned(loop_size, data_width))
        Goto     state2
      }
      state2.on {
        Case(cond){[state3, state5]}
      }
      state3.on{
        counter  <= counter + To_Unsigned(1, data_width)
        Goto     state4
      }
      state4.on {
        Goto     state1
      }
      state5.on {
      }
    end
  end
end

puts design.to_exp("")


