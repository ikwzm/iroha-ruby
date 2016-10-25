require_relative '../lib/iroha/builder/simple'

include Iroha::Builder::Simple

design = IDesign :design do
  IModule :mod do
    ITable :tab do
      Register  :mul_u5  => Unsigned(5)
      Register  :mul_u6  => Unsigned(6)
      Register  :mul_u7  => Unsigned(7)
      Register  :mul_u8  => Unsigned(8)
      Register  :mul_u9  => Unsigned(9)
      Register  :mul_u35 => Unsigned(35)
      Register  :mul_s5  => Signed(5)
      Register  :mul_s6  => Signed(6)
      Register  :mul_s7  => Signed(7)
      Register  :mul_s8  => Signed(8)
      Register  :mul_s9  => Signed(9)
      Register  :mul_s35 => Signed(35)
      IState    :state1
      IState    :state2
      IState    :state3
      state1.on {
        mul_u35 <= (mul_u6 * mul_u7) * (mul_u9 * mul_u8) * mul_u5
        mul_s35 <= (mul_s6 * mul_s7) * (mul_s9 * mul_s8) * mul_s5
      }      
      state2.on {
        mul_u35 <= (mul_u6 * mul_s6) * (mul_u7 * mul_s7) * mul_s5
        mul_s35 <= (mul_u8 * mul_s8) * (mul_u9 * mul_s9) * mul_u5
      }      
      state3.on {
        mul_u35 <= (mul_s6 * mul_u6) * (mul_s7 * mul_u7) * mul_s5
        mul_s35 <= (mul_s8 * mul_u8) * (mul_s9 * mul_u9) * mul_u5
      }      
    end
  end
end
puts design.to_exp("")
