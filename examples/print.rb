require_relative '../lib/iroha/builder/simple'

include Iroha::Builder::Simple

design = IDesign :design do
  IModule :mod do
    ITable :tab do
      IState       :st1
      IState       :st2
      Register     :r1   => Unsigned( 0) <= 1
      Register     :r123 => Unsigned(32) <= 123
      st1.on {
        Goto   st2
        Print  r123
        Assert r1
      }
      st2.on {
        Goto   st1
      }
    end
  end
end

puts design.to_exp("")
