require_relative '../lib/iroha/builder/simple'

include Iroha::Builder::Simple

design = IDesign :design do
  IModule :add do
    ITable :table do
      Register  :counter  => Unsigned(32)
      Constant  :ten      => Unsigned(32) <= 10
      Gt        :gt       , [Unsigned(32), Unsigned(32)], [Unsigned( 1)]
      Register  :cond     => Unsigned( 0)
      Add       :adder    , [Unsigned(32), Unsigned(32)], [Unsigned(32)]
      Constant  :one      => Unsigned(32) <= 1
      IState    :state1
      IState    :state2
      IState    :state3
      IState    :state4
      IState    :state5

      state1.on {
        cond     <= gt(counter, ten)
        Goto     state2
      }
      state2.on {
        Case(cond){[state3, state5]}
      }
      state3.on{
        counter  <= adder(counter, one)
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


