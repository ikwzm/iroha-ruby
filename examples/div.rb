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

      Wire      :zi_l      , Unsigned(z_width)
      Constant  :zi_h      , Unsigned(d_width) <= 0
      Wire      :zi_i      , Unsigned(z_width+d_width)
      Register  :zi        , Array.new(z_width, Unsigned(z_width+d_width))
      Register  :di        , Array.new(z_width, Unsigned(        d_width))

      Constant  :pr_high   , Unsigned(32) <= d_width+z_width-1
      Constant  :pr_low    , Unsigned(32) <=         z_width-1
      Wire      :pr        , Array.new(z_width, Unsigned(d_width+1))
      Wire      :sb        , Array.new(z_width, Unsigned(d_width+1))

      Constant  :ms_pos    , Unsigned(32) <= d_width
      Constant  :mx_high   , Unsigned(32) <= d_width-1
      Constant  :mx_low    , Unsigned(32) <= 0
      Wire      :m0        , Array.new(z_width, Unsigned(d_width))
      Wire      :m1        , Array.new(z_width, Unsigned(d_width))
      Wire      :ms        , Array.new(z_width, Unsigned(1))
      Wire      :mx        , Array.new(z_width, Unsigned(d_width))

      Constant  :zl_high   , Unsigned(32) <= z_width-1
      Constant  :zl_low    , Unsigned(32) <= 1
      Wire      :zl        , Array.new(z_width, Unsigned(z_width-1))
      Wire      :zb        , Array.new(z_width, Unsigned(1))
      Wire      :zo        , Array.new(z_width, Unsigned(z_width+d_width))

      Constant  :zr_high   , Unsigned(32) <= z_width+d_width-1
      Constant  :zr_low    , Unsigned(32) <= z_width
      Constant  :zq_high   , Unsigned(32) <= z_width-1
      Constant  :zq_low    , Unsigned(32) <= 0
      Wire      :zr        , Unsigned(d_width)
      Wire      :zq        , Unsigned(z_width)

      stage = Array.new
      z_width.downto(0) do |i|
        st = IStage("stage_#{i}".to_sym)
        stage[i] = st[0]
      end

      z_width.downto(0) do |i|
        stage[i].on {
          if i == z_width then
            start   <= i_valid
            zi_l    <= dividend
            zi_i    <= BitConcat(zi_h, zi_l)
            zi[i-1] <= zi_i
            di[i-1] <= divisor
            Goto stage[i-1]
          else
            pr[i] <= BitSel(zi[i], pr_high, pr_low)
            sb[i] <= Sub(pr[i], di[i])
            m1[i] <= BitSel(pr[i], mx_high, mx_low)
            m0[i] <= BitSel(sb[i], mx_high, mx_low)
            ms[i] <= BitSel(sb[i], ms_pos , ms_pos)
            mx[i] <= Select(ms[i], m1[i], m0[i])
            zl[i] <= BitSel(zi[i], zl_high, zl_low)
            zb[i] <= BitInv(ms[i])
            zo[i] <= BitConcat(mx[i], zl[i], zb[i])
            if i > 0 then
              zi[i-1] <= zo[i]
              di[i-1] <= di[i]
              Goto stage[i-1]
            else
              zq <= BitSel(zo[i], zq_high, zq_low)
              zr <= BitSel(zo[i], zr_high, zr_low)
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
