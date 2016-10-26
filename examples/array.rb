require_relative '../lib/iroha/builder/simple'

include Iroha::Builder::Simple

design = IDesign :design do
  IModule :mod do
    ITable :tab_w do
      addr_width = 10
      data_width = 32
      IState       :st1
      IState       :st2
      Register     :rdata => Unsigned(data_width)
      IrohaArray   :mem   , addr_width, Unsigned(data_width), :INTERNAL, :RAM
      st1.on {
        mem[To_Unsigned(0,addr_width)] <= To_Unsigned(123,data_width)
        Goto  st2
      }
      st2.on {
        rdata <= mem[To_Unsigned(0,addr_width)]
        Goto  st1
      }
    end
  end
end

puts design.to_exp("")
