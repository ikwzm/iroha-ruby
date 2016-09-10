require_relative '../lib/iroha/builder/simple'

include Iroha::Builder::Simple

design = IDesign :design do

  IModule :mod_top do
    ITable :shared  do
      Register   :reg_top , Unsigned(32)
    end
    ITable :tab_top do
      ForeignReg :foreign_reg2, Ref(:mod_sub, :shared, :reg_sub)
      Register   :reg2        , Unsigned(32)
      IState     :state1
      IState     :state2
      state1.on {
        reg2 <= foreign_reg2
        Goto state2
      }
      state2.on {
        foreign_reg2 <= reg2
        Goto state1
      }
    end
  end

  mod_top.IModule :mod_sub do
    ITable :shared  do
      Register   :reg_sub , Unsigned(32)
    end
    ITable :tab_sub do
      ForeignReg :foreign_reg1, Ref(:mod_top, :shared, :reg_top)
      Register   :reg1        , Unsigned(32)
      IState     :state1
      IState     :state2
      state1.on {
        reg1 <= foreign_reg1
        Goto state2
      }
      state2.on {
        foreign_reg1 <= reg1
        Goto state1
      }
    end
  end

end

puts design.to_exp("")
