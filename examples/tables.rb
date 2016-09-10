require_relative '../lib/iroha/builder/simple'

include Iroha::Builder::Simple

design = IDesign :design do

  IModule :mod do
    ITable :shared  do
      Register   :shared_reg  , Unsigned(32)
    end
    ITable :tab1 do
      IState     :st1
      IState     :st12
      ForeignReg :foreign_reg1, @owner_design.mod.shared.shared_reg
      Resource   :Set, nil, [], [], {}, {}
      Register   :r11         , Unsigned(32) <= 123
      Register   :r12         , Unsigned(32)
      st1.on {
        foreign_reg1 <= r11
      }
      st12.on {
        r12 <= foreign_reg1
      }
    end
    ITable :tab2 do
      IState     :st2
      IState     :st22
      ForeignReg :foreign_reg2, @owner_design.mod.shared.shared_reg
      Register   :r21         , Unsigned(32) <= 456
      Register   :r22         , Unsigned(32) <= 789
      st2.on {
        foreign_reg2 <= r21
      }
      st22.on {
        foreign_reg2 <= r22
      }
    end
  end
end

puts design.to_exp("")
