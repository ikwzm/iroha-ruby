require_relative '../lib/iroha/builder/simple'

include Iroha::Builder::Simple

design = IDesign :design do
  IModule :mod do
    ITable :tab do
      Register  :data_u0  => Unsigned(7)
      Register  :data_u1  => Unsigned(7)
      Register  :data_u2  => Unsigned(4)
      Register  :data_u3  => Unsigned(5)
      Register  :data_u4  => Unsigned(6)
      Register  :data_u5  => Unsigned(4)
      Register  :data_u6  => Unsigned(5)
      Register  :data_u7  => Unsigned(6)
      Register  :data_u8  => Unsigned(6)
      Register  :data_s0  => Signed(7)
      Register  :data_s1  => Signed(7)
      Register  :data_s2  => Signed(4)
      Register  :data_s3  => Signed(5)
      Register  :data_s4  => Signed(6)
      Register  :data_s5  => Signed(4)
      Register  :data_s6  => Signed(5)
      Register  :data_s7  => Signed(6)
      Register  :data_s8  => Signed(6)
      IState    :state1
      IState    :state2
      IState    :state3
      IState    :state4
      state1.on {
        data_u8 <= Select( (data_u0 == data_u1), (data_u2 & data_u3 & data_u4),  (data_u5 | data_u6 | data_u7))
        data_s8 <= Select( (data_s0 != data_s1), (data_s2 & data_s3 & data_s4),  (data_s5 | data_s6 | data_s7))
      }      
      state2.on {
        data_u8 <= Select( (data_u0 >  data_u1), (data_u2 ^ data_u3 ^ data_u4), ~(data_u5 ^ data_u6 ^ data_u7))
        data_s8 <= Select(!(data_s0 >  data_s1), (data_s2 ^ data_s3 ^ data_s4), ~(data_s5 ^ data_s6 ^ data_s7))
      }      
      state3.on {
        data_u0 <= Select( (data_u0 >= data_u1), ~data_u0, ~data_u1)
        data_s0 <= Select(!(data_s0 >= data_s1), ~data_s0, ~data_s1)
      }      
      state4.on {
        data_u0 <= Select((data_u0 > data_u1),
                          Select((data_u2 < data_u3), data_u0, data_u1),
                          Select((data_u1 < data_u2), data_u1, data_u0))
      }      
    end
  end
end
puts design.to_exp("")
