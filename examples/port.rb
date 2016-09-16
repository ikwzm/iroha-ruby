require_relative '../lib/iroha/builder/simple'

include Iroha::Builder::Simple

design = IDesign :design do
  IModule :mod do
    ITable :tab_1 do
      Register   :din     , Unsigned(32)
      Constant   :dout    , Unsigned(32) <= 8
      PortInput  :data_in , Unsigned(32), Ref(:mod, :tab_2, :data_out)
      PortOutput :data_out, Unsigned(32)
      IState     :st11
      IState     :st12
      IState     :st13
      st11.on {
        Goto st12
        din <= data_in
      }
      st12.on {
        Goto st13
        data_out <= dout
      }
      st13.on {
      }
    end
    ITable :tab_2 do
      Register   :din     , Unsigned(32)
      Constant   :dout    , Unsigned(32) <= 8
      PortInput  :data_in , Unsigned(32)
      PortOutput :data_out, Unsigned(32)
      IState     :st21
      IState     :st22
      IState     :st23
      st21.on {
        Goto st22
        din <= data_in
      }
      st22.on {
        Goto st23
        data_out <= dout
      }
      st23.on {
      }
    end
    ITable :tab_3 do
      Register   :din     , Unsigned(32)
      Constant   :dout    , Unsigned(32) <= 8
      PortInput  :data_in , Unsigned(32)
      PortOutput :data_out, Unsigned(32)
      IState     :st31
      st31.on {
        din <= data_in
      }
    end
    tab_2.data_in <= tab_1.data_out
    tab_3.data_in <= tab_1.data_out
  end
end

puts design.to_exp("")
