require_relative '../lib/iroha/builder/simple'

include Iroha::Builder::Simple

design = IDesign :design do
  IModule :mod do
    ITable :tab do
      Wire       :req     => Unsigned( 1)
      Register   :counter => Unsigned(32) <= 0
      Constant   :one     => Unsigned(32) <= 1
      ExtInput   :data_in => 1
      DataFlowIn :flow_in , Unsigned( 1)

      IState     :state1
      IState     :state2
      IState     :state3

      state1.on {
        req     <= data_in
        flow_in <= req
        Goto state2
      }
      state2.on {
        counter <= counter + one
        Goto state3
      }
      state3.on {
      }
    end
  end
end

puts design.to_exp("")
