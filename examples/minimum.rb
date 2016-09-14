require_relative '../lib/iroha/builder/simple'

include Iroha::Builder::Simple

design = IDesign :design do
  IModule :mod do
    ITable :tab do
      IState       :st1
      IState       :st2
      Register     :r1   ,   Signed(32)
      Register     :r2   ,   Signed(32) <= 123
      st1.on {
        Goto   st2
        r1 <= r2
      }
    end
  end
  mod._params.update({"RESET-NAME" => "reset"})
end
design._params.update({"RESET-POLARITY" => "true"})

puts design.to_exp("")
