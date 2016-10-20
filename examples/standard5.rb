require_relative '../lib/iroha/builder/simple'

include Iroha::Builder::Simple

design = IDesign :design do
  IModule :mod do
    ITable :tab do
      Register  :data_u0 , Unsigned(32)
      Register  :data_u1 , Unsigned(32)
      Register  :data_u2 , Unsigned(32)
      Register  :data_u3 , Unsigned(32)
      Register  :data_u4 , Unsigned(32)
      Register  :data_s0 , Signed(32)
      Register  :data_s1 , Signed(32)
      Register  :data_s2 , Signed(32)
      Register  :data_s3 , Signed(32)
      Register  :data_s4 , Signed(32)
      IState    :state1
      state1.on {
        data_u4 <= BitConcat(
          BitSel(data_u3, To_Unsigned(31,8), To_Unsigned(23,8)),
          BitSel(data_u2, To_Unsigned(22,8), To_Unsigned(18,8)),
          BitSel(data_u1, To_Unsigned(17,8), To_Unsigned( 8,8)),
          BitSel(data_u0, To_Unsigned( 7,8), To_Unsigned( 0,8)))
        data_s4 <= BitConcat(
          BitSel(data_s3, To_Unsigned(31,8), To_Unsigned(22,8)),
          BitSel(data_s2, To_Unsigned(21,8), To_Unsigned(14,8)),
          BitSel(data_s1, To_Unsigned(13,8), To_Unsigned(11,8)),
          BitSel(data_s0, To_Unsigned(10,8), To_Unsigned( 0,8)))
      }      
    end
  end
end
puts design.to_exp("")
