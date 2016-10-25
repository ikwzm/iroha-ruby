require_relative '../lib/iroha/builder/simple'

include Iroha::Builder::Simple

design = IDesign :design do
  IModule :mod do
    IFlow :tab do
      Start      :start
      Register   :counter => Unsigned(32) <= 0
      ExtInput   :request => 1

      IStage     :stage1, :stage2, :stage3

      stage1.on {
        start   <= request
      }
      stage2.on {
        counter <= counter + To_Unsigned(1, 32)
      }
      stage3.on {
      }
    end
  end
end

puts design.to_exp("")
