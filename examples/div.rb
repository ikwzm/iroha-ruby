require_relative '../lib/iroha/builder/simple'

include Iroha::Builder::Simple

design = IDesign :design do
  IModule :div do
    IFlow :flow do
      z_width = 32
      d_width = 16
      Start     :start
      ExtInput  :i_valid   , 0
      ExtInput  :dividend  , z_width
      ExtInput  :divisor   , d_width
      ExtOutput :quotient  , z_width
      ExtOutput :remainder , d_width
      ExtOutput :o_valid   , 0

      Register  :zi        , Array.new(z_width, Unsigned(z_width+d_width))
      Register  :di        , Array.new(z_width, Unsigned(        d_width))

      Constant  :pr_high   , Unsigned(32) <= d_width+z_width-1
      Constant  :pr_low    , Unsigned(32) <=         z_width-1

      Constant  :ms_pos    , Unsigned(32) <= d_width
      Constant  :mx_high   , Unsigned(32) <= d_width-1
      Constant  :mx_low    , Unsigned(32) <= 0

      Constant  :zl_high   , Unsigned(32) <= z_width-2
      Constant  :zl_low    , Unsigned(32) <= 0

      Constant  :zr_high   , Unsigned(32) <= z_width+d_width-1
      Constant  :zr_low    , Unsigned(32) <= z_width
      Constant  :zq_high   , Unsigned(32) <= z_width-1
      Constant  :zq_low    , Unsigned(32) <= 0

      stage = Array.new
      z_width.downto(0) do |i|
        st = IStage("stage_#{i}".to_sym)
        stage[i] = st[0]
      end

      z_width.downto(0) do |i|
        stage[i].on {
          if i == z_width then
            Wire      :zi_l , Unsigned(z_width)
            Constant  :zi_h , Unsigned(d_width) <= 0
            Wire      :zi_i , Unsigned(z_width+d_width)
            start   <= i_valid
            zi_l    <= dividend
            zi_i    <= BitConcat(zi_h, zi_l)
            zi[i-1] <= zi_i
            di[i-1] <= divisor
            Goto stage[i-1]
          else
            Wire  :pr , Unsigned(d_width+1)
            Wire  :sb , Unsigned(d_width+1)
            Wire  :m0 , Unsigned(d_width)
            Wire  :m1 , Unsigned(d_width)
            Wire  :ms , Unsigned(1)
            Wire  :mx , Unsigned(d_width)
            Wire  :zl , Unsigned(z_width-1)
            Wire  :zb , Unsigned(1)
            Wire  :zo , Unsigned(z_width+d_width)
            pr <= BitSel(zi[i], pr_high, pr_low)
            sb <= Sub(pr, di[i])
            m1 <= BitSel(pr, mx_high, mx_low)
            m0 <= BitSel(sb, mx_high, mx_low)
            ms <= BitSel(sb, ms_pos , ms_pos)
            mx <= Select(ms, m0, m1)
            zl <= BitSel(zi[i], zl_high, zl_low)
            zb <= BitInv(ms)
            zo <= BitConcat(mx, zl, zb)
            if i > 0 then
              zi[i-1] <= zo
              di[i-1] <= di[i]
              Goto stage[i-1]
            else
              Wire :zr, Unsigned(d_width)
              Wire :zq, Unsigned(z_width)
              zq <= BitSel(zo, zq_high, zq_low)
              zr <= BitSel(zo, zr_high, zr_low)
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
