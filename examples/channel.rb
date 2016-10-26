require_relative '../lib/iroha/builder/simple'

include Iroha::Builder::Simple

design = IDesign :design do
  IModule :mod do
    ITable :tab_w do
      ChannelWrite :cha_w  => Unsigned(32)
      Constant     :val_w  => Unsigned(32) <= 123
      IState       :st10
      IState       :st11
      st10.on {
        cha_w <= val_w
        Goto  st11
      }
      st11.on {
        Goto  st10
      }
    end
    ITable :tab_r do
      ChannelRead  :cha_r => Unsigned(32)
      Register     :val_r => Unsigned(32)
      IState       :st20
      IState       :st21
      IState       :st22
      st20.on {
        val_r <= cha_r
        Goto  st21
      }
      st21.on {
        Print val_r
        Goto  st22
      }
      st22.on {
        Goto  st20
      }
    end
  end
  mod.tab_r.cha_r <= mod.tab_w.cha_w
end

puts design.to_exp("")
