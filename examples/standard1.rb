require_relative '../lib/iroha/builder/simple'

include Iroha::Builder::Simple

design = IDesign :design do
  IModule :mod do
    ITable :tab do
      Register  :add_u5  => Unsigned(5)
      Register  :add_u6  => Unsigned(6)
      Register  :add_u7  => Unsigned(7)
      Register  :add_u8  => Unsigned(8)
      Register  :add_u9  => Unsigned(9)
      Register  :add_u12 => Unsigned(12)
      Register  :add_s5  => Signed(5)
      Register  :add_s6  => Signed(6)
      Register  :add_s7  => Signed(7)
      Register  :add_s8  => Signed(8)
      Register  :add_s9  => Signed(9)
      Register  :add_s12 => Signed(12)
      IState    :state1
      IState    :state2
      state1.on {
        add_u12 <= (add_u6 + add_u7) + (add_u8 + add_u9) + add_u5
        add_s12 <= (add_s6 + add_s7) + (add_s8 + add_s9) + add_s5
      }      
      state2.on {
        add_u12 <= (add_u6 + add_s6) + (add_u7 + add_s7) + add_s5
        add_s12 <= (add_u8 + add_s8) + (add_u9 + add_s9) + add_u5
      }      
    end
  end
end
puts design.to_exp("")
