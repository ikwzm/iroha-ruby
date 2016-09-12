module Iroha
  module Writer
    module Verilog
      @@iroha_command = "iroha"
    end
  end
  class IDesign
    include Iroha::Writer::Verilog
    def to_verilog(file_name)
      iroha_command = @@iroha_command + " - -v"
      if file_name != nil
        iroha_command = iroha_command + " -o #{file_name}"
      end
      IO.popen(iroha_command, "w") do |io|
        io.puts self.to_exp("")
      end
    end
  end
end
