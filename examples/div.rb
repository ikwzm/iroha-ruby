require_relative '../lib/iroha/builder/simple'

include Iroha::Builder::Simple

design = IDesign :design do
  IModule :div do
    IFlow :flow do
      z_width = 32
      d_width = 16
      Start     :start
      ExtInput  :i_valid   => Unsigned(0)
      ExtInput  :dividend  => Unsigned(z_width)
      ExtInput  :divisor   => Unsigned(d_width)
      ExtOutput :quotient  => Unsigned(z_width)
      ExtOutput :remainder => Unsigned(d_width)
      ExtOutput :o_valid   => Unsigned(0) <= 0

      Register  :zi        => Array.new(z_width, Unsigned(z_width+d_width))
      Register  :di        => Array.new(z_width, Unsigned(        d_width))

      Constant  :pr_high   => Unsigned(32) <= d_width+z_width-1
      Constant  :pr_low    => Unsigned(32) <=         z_width-1

      Constant  :ms_pos    => Unsigned(32) <= d_width
      Constant  :mx_high   => Unsigned(32) <= d_width-1
      Constant  :mx_low    => Unsigned(32) <= 0

      Constant  :zl_high   => Unsigned(32) <= z_width-2
      Constant  :zl_low    => Unsigned(32) <= 0

      Constant  :zr_high   => Unsigned(32) <= z_width+d_width-1
      Constant  :zr_low    => Unsigned(32) <= z_width
      Constant  :zq_high   => Unsigned(32) <= z_width-1
      Constant  :zq_low    => Unsigned(32) <= 0

      Constant  :done      => Unsigned( 0) <= 1

      stage = Array.new
      z_width.downto(0) do |i|
        st = IStage("stage_#{i}".to_sym)
        stage[i] = st[0]
      end

      z_width.downto(0) do |i|
        stage[i].on {
          if i == z_width then
            Constant :zi_h => Unsigned(d_width)         <= 0
            Wire     :zi_l => Unsigned(z_width)         <= dividend
            Wire     :zi_i => Unsigned(z_width+d_width) <= BitConcat(zi_h, zi_l)
            start   <= i_valid
            zi[i-1] <= zi_i
            di[i-1] <= divisor
            Goto stage[i-1]
          else
            Wire     :pr   => Unsigned(d_width+1)       <= BitSel(zi[i], pr_high, pr_low)
            Wire     :sb   => Unsigned(d_width+1)       <= Sub(pr, di[i])
            Wire     :m0   => Unsigned(d_width)         <= BitSel(sb, mx_high, mx_low)
            Wire     :m1   => Unsigned(d_width)         <= BitSel(pr, mx_high, mx_low)
            Wire     :ms   => Unsigned(1)               <= BitSel(sb, ms_pos , ms_pos)
            Wire     :mx   => Unsigned(d_width)         <= Select(ms, m0, m1)
            Wire     :zl   => Unsigned(z_width-1)       <= BitSel(zi[i], zl_high, zl_low)
            Wire     :zb   => Unsigned(1)               <= BitInv(ms)
            Wire     :zo   => Unsigned(z_width+d_width) <= BitConcat(mx, zl, zb)
            if i > 0 then
              zi[i-1] <= zo
              di[i-1] <= di[i]
              Goto stage[i-1]
            else
              Wire   :zr   => Unsigned(d_width)         <= BitSel(zo, zr_high, zr_low)
              Wire   :zq   => Unsigned(z_width)         <= BitSel(zo, zq_high, zq_low)
              o_valid   <= done
              quotient  <= zq
              remainder <= zr
            end
          end
        }
      end
    end
  end
end

puts design.to_exp("")
