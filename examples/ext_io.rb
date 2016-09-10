require_relative '../lib/iroha/builder/simple'

include Iroha::Builder::Simple

design = IDesign :design do
  IModule :mod do
    ITable :tab do
      IState    :st1
      IState    :st2
      IState    :st3
      ExtInput  :data_in , 32
      Register  :r       , Unsigned(32)
      ExtOutput :data_out, 32

      st1.on {
        Goto st2
        r <= data_in
      }
      st2.on {
        Goto st3
        data_out <= To_Unsigned(123,32)
      }
      st3.on {
      }
    end
  end
end

puts design.to_exp("")
      
