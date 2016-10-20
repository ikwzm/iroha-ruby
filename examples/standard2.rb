require_relative '../lib/iroha/builder/simple'

include Iroha::Builder::Simple

design = IDesign :design do
  IModule :mod do
    ITable :tab do
      Register  :sub_u5 , Unsigned(5)
      Register  :sub_u6 , Unsigned(6)
      Register  :sub_u7 , Unsigned(7)
      Register  :sub_u8 , Unsigned(8)
      Register  :sub_u9 , Unsigned(9)
      Register  :sub_u12, Unsigned(12)
      Register  :sub_s5 , Signed(5)
      Register  :sub_s6 , Signed(6)
      Register  :sub_s7 , Signed(7)
      Register  :sub_s8 , Signed(8)
      Register  :sub_s9 , Signed(9)
      Register  :sub_s12, Signed(12)
      IState    :state1
      IState    :state2
      IState    :state3
      state1.on {
        sub_u12 <= (sub_u6 - sub_u7) - (sub_u9 - sub_u8) - sub_u5
        sub_s12 <= (sub_s6 - sub_s7) - (sub_s9 - sub_s8) - sub_s5
      }      
      state2.on {
        sub_u12 <= (sub_u6 - sub_s6) - (sub_u7 - sub_s7) - sub_s5
        sub_s12 <= (sub_u8 - sub_s8) - (sub_u9 - sub_s9) - sub_u5
      }      
      state3.on {
        sub_u12 <= (sub_s6 - sub_u6) - (sub_s7 - sub_u7) - sub_s5
        sub_s12 <= (sub_s8 - sub_u8) - (sub_s9 - sub_u9) - sub_u5
      }      
    end
  end
end
puts design.to_exp("")
