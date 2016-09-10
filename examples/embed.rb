require_relative '../lib/iroha/builder/simple'

include Iroha::Builder::Simple

design = IDesign :design do
  IModule :mod do
    ITable :tab do
      IState       :st1
      IState       :st2
      Embedded     :res, [Unsigned(32)], [],
                         {:NAME  => "mod_hello"  ,
                          :FILE  => "mod_hello.v",
                          :CLOCK => "clk"        ,
                          :RESET => "rst_n"      ,
                          :ARGS  => "arg_hello"  ,
                          :REQ   => "req_hello"  ,
                          :ACK   => "ack_hello"  }
      st1.on {
        Goto   st2
        res <= To_Unsigned(123,32)
      }
    end
  end
end

puts design.to_exp("")
