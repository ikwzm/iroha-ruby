require_relative '../lib/iroha/builder/simple'

include Iroha::Builder::Simple

design = IDesign :design do
  IModule :mod do
    ITable :tab do
      Register  :data_u0 , Unsigned(32)
      Register  :data_u1 , Unsigned(32)
      Register  :data_u2 , Unsigned(32)
      Register  :data_s0 , Signed(32)
      Register  :data_s1 , Signed(32)
      Register  :data_s2 , Signed(32)
      Register  :data_s3 , Signed(32)
      Register  :data_s4 , Signed(32)
      IState    :state1
      state1.on {
        data_u2 <= BitConcat(
          BitSel(Shift(data_u0, To_Signed(-1,8)), To_Unsigned(15,8), To_Unsigned(0,8)),
          BitSel(Shift(data_u1, To_Signed( 5,8)), To_Unsigned(23,8), To_Unsigned(8,8)))
        data_s2 <= BitConcat(
          BitSel(Shift(data_s0, To_Signed( 7,8)), To_Unsigned(23,8), To_Unsigned(8,8)),
          BitSel(Shift(data_s1, To_Signed(-3,8)), To_Unsigned(23,8), To_Unsigned(8,8)))
      }      
    end
  end
end
puts design.to_exp("")
