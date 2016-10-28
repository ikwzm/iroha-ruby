require_relative '../lib/iroha/builder/simple'

include Iroha::Builder::Simple

design = IDesign :design do
  IModule :fdiv do
    IFlow :flow do
      a_width          = 32
      a_fraction_width = 23
      a_exponent_width =  8

      b_width          = 32
      b_fraction_width = 23
      b_exponent_width =  8

      o_width          = 32
      o_fraction_width = 23
      o_exponent_width =  8

      s_fraction_width = o_fraction_width + 4
      
      z_fraction_width = a_fraction_width + s_fraction_width
      z_exponent_width = a_exponent_width
      
      d_fraction_width = b_fraction_width + 1
      d_exponent_width = b_exponent_width

      i_exponent_width = (a_exponent_width > b_exponent_width) ? a_exponent_width : b_exponent_width
      q_exponent_width = (o_exponent_width > i_exponent_width) ? o_exponent_width + 2 : i_exponent_width + 2
      q_fraction_width = (z_fraction_width + d_fraction_width)

      Start     :start
      ExtInput  :i_valid             => Unsigned(0)

      ExtOutput :z_out               => Unsigned(o_width)
      ExtOutput :z_valid             => Unsigned(0) <= 0

      Constant  :a_exponent_offset   => Unsigned(a_exponent_width) <= 2**(a_exponent_width-1)-1
      Constant  :a_exponent_all_0    => Unsigned(a_exponent_width) <= 0
      Constant  :a_exponent_all_1    => Unsigned(a_exponent_width) <= (0..a_exponent_width-1).to_a.inject(0){|d,n| d = d + 2**n}
      Constant  :a_fraction_all_0    => Unsigned(a_fraction_width) <= 0
      ExtInput  :a_in                => Unsigned(a_width)

      Constant  :b_exponent_offset   => Unsigned(b_exponent_width) <= 2**(b_exponent_width-1)-1
      Constant  :b_exponent_all_0    => Unsigned(b_exponent_width) <= 0
      Constant  :b_exponent_all_1    => Unsigned(b_exponent_width) <= (0..b_exponent_width-1).to_a.inject(0){|d,n| d = d + 2**n}
      Constant  :b_fraction_all_0    => Unsigned(b_fraction_width) <= 0
      ExtInput  :b_in                => Unsigned(b_width)

      Constant  :o_exponent_offset   => Unsigned(o_exponent_width) <= 2**(o_exponent_width-1)-1
      Constant  :o_exponent_all_1    => Unsigned(o_exponent_width) <= (0..o_exponent_width-1).to_a.inject(0){|d,n| d = d + 2**n}

      IStage    :stage1
      stage2 = Array.new
      z_fraction_width.downto(0) do |i|
        st = IStage("stage2_#{i}".to_sym)
        stage2[i] = st[0]
      end
      IStage    :stage3, :stage4, :stage5

      Register  :stage1_a_fraction          => Unsigned(a_fraction_width+1)
      Register  :stage1_a_exponent          => Unsigned(a_exponent_width)
      Register  :stage1_a_sign              => Unsigned(0)
      Register  :stage1_a_exponent_is_all_0 => Unsigned(0)
      Register  :stage1_a_fraction_is_all_0 => Unsigned(0)

      Register  :stage1_b_fraction          => Unsigned(b_fraction_width+1)
      Register  :stage1_b_exponent          => Unsigned(b_exponent_width)
      Register  :stage1_b_sign              => Unsigned(0)
      Register  :stage1_b_exponent_is_all_0 => Unsigned(0)
      Register  :stage1_b_fraction_is_all_0 => Unsigned(0)

      Register  :stage2_zi                  => Array.new(z_fraction_width+1, Unsigned(q_fraction_width))
      Register  :stage2_di                  => Array.new(z_fraction_width+1, Unsigned(d_fraction_width))
      Register  :stage2_exponent            => Array.new(z_fraction_width+1,   Signed(q_exponent_width))
      Register  :stage2_sign                => Array.new(z_fraction_width+1, Unsigned(0))
      Register  :stage2_a_is_zero           => Array.new(z_fraction_width+1, Unsigned(0))
      Register  :stage2_a_is_inf            => Array.new(z_fraction_width+1, Unsigned(0))
      Register  :stage2_a_is_nan            => Array.new(z_fraction_width+1, Unsigned(0))
      Register  :stage2_b_is_zero           => Array.new(z_fraction_width+1, Unsigned(0))
      Register  :stage2_b_is_inf            => Array.new(z_fraction_width+1, Unsigned(0))
      Register  :stage2_b_is_nan            => Array.new(z_fraction_width+1, Unsigned(0))

      Constant  :stage2_pr_high             => Unsigned(32) <= q_fraction_width-1
      Constant  :stage2_pr_low              => Unsigned(32) <= z_fraction_width-1

      Constant  :stage2_ms_pos              => Unsigned(32) <= d_fraction_width
      Constant  :stage2_mx_high             => Unsigned(32) <= d_fraction_width-1
      Constant  :stage2_mx_low              => Unsigned(32) <= 0

      Constant  :stage2_zl_high             => Unsigned(32) <= z_fraction_width-2
      Constant  :stage2_zl_low              => Unsigned(32) <= 0

      Constant  :stage2_zr_high             => Unsigned(32) <= q_fraction_width-1
      Constant  :stage2_zr_low              => Unsigned(32) <= z_fraction_width
      Constant  :stage2_zq_high             => Unsigned(32) <= z_fraction_width-1
      Constant  :stage2_zq_low              => Unsigned(32) <= 0

      Register  :stage3_fraction            => Unsigned(s_fraction_width)
      Register  :stage3_exponent            =>   Signed(q_exponent_width)
      Register  :stage3_sign                => Unsigned(0)
      Register  :stage3_a_is_zero           => Unsigned(0)
      Register  :stage3_a_is_inf            => Unsigned(0)
      Register  :stage3_a_is_nan            => Unsigned(0)
      Register  :stage3_b_is_zero           => Unsigned(0)
      Register  :stage3_b_is_inf            => Unsigned(0)
      Register  :stage3_b_is_nan            => Unsigned(0)

      Register  :stage4_fraction            => Unsigned(s_fraction_width-3)
      Register  :stage4_exponent            =>   Signed(q_exponent_width)
      Register  :stage4_sign                => Unsigned(0)
      Register  :stage4_a_is_zero           => Unsigned(0)
      Register  :stage4_a_is_inf            => Unsigned(0)
      Register  :stage4_a_is_nan            => Unsigned(0)
      Register  :stage4_b_is_zero           => Unsigned(0)
      Register  :stage4_b_is_inf            => Unsigned(0)
      Register  :stage4_b_is_nan            => Unsigned(0)

      stage1.on {
        start  <= i_valid

        Constant  :a_fraction_low_pos  => Unsigned(32)               <= 0
        Constant  :a_fraction_high_pos => Unsigned(32)               <= a_fraction_width-1
        Constant  :a_exponent_low_pos  => Unsigned(32)               <= a_fraction_width
        Constant  :a_exponent_high_pos => Unsigned(32)               <= a_fraction_width + a_exponent_width-1
        Constant  :a_sign_pos          => Unsigned(32)               <= a_fraction_width + a_exponent_width
        Wire      :a_data_in           => Unsigned(a_width)          <= a_in
        Wire      :a_exponent_in       => Unsigned(a_exponent_width) <= BitSel(a_data_in, a_exponent_high_pos, a_exponent_low_pos)
        Wire      :a_fraction_in       => Unsigned(a_fraction_width) <= BitSel(a_data_in, a_fraction_high_pos, a_fraction_low_pos)
        Constant  :a_fraction_lo       => Unsigned(2)                <= 0
        Wire      :a_sign_in           => Unsigned(0)                <= BitSel(a_data_in, a_sign_pos         , a_sign_pos        )
        Wire      :a_exponent_zero     => Unsigned(0)                <= (a_exponent_in == a_exponent_all_0)
        Wire      :a_fraction_msb      => Unsigned(1)                <= BitInv(a_exponent_zero)

        stage1_a_fraction          <= BitConcat(a_fraction_msb, a_fraction_in)
        stage1_a_exponent          <= a_exponent_in
        stage1_a_sign              <= a_sign_in
        stage1_a_exponent_is_all_0 <= a_exponent_zero
        stage1_a_fraction_is_all_0 <= (a_fraction_in == a_fraction_all_0)

        Constant  :b_fraction_low_pos  => Unsigned(32)               <= 0
        Constant  :b_fraction_high_pos => Unsigned(32)               <= b_fraction_width-1
        Constant  :b_exponent_low_pos  => Unsigned(32)               <= b_fraction_width
        Constant  :b_exponent_high_pos => Unsigned(32)               <= b_fraction_width + b_exponent_width-1
        Constant  :b_sign_pos          => Unsigned(32)               <= b_fraction_width + b_exponent_width
        Wire      :b_data_in           => Unsigned(b_width)          <= b_in
        Wire      :b_exponent_in       => Unsigned(b_exponent_width) <= BitSel(b_data_in, b_exponent_high_pos, b_exponent_low_pos)
        Wire      :b_fraction_in       => Unsigned(b_fraction_width) <= BitSel(b_data_in, b_fraction_high_pos, b_fraction_low_pos)
        Wire      :b_sign_in           => Unsigned(0)                <= BitSel(b_data_in, b_sign_pos         , b_sign_pos        )
        Wire      :b_exponent_zero     => Unsigned(0)                <= (b_exponent_in == b_exponent_all_0)
        Wire      :b_fraction_msb      => Unsigned(1)                <= BitInv(b_exponent_zero)

        stage1_b_fraction          <= BitConcat(b_fraction_msb, b_fraction_in)
        stage1_b_exponent          <= b_exponent_in
        stage1_b_sign              <= b_sign_in
        stage1_b_exponent_is_all_0 <= b_exponent_zero
        stage1_b_fraction_is_all_0 <= (b_fraction_in == b_fraction_all_0)
        Goto stage2[z_fraction_width]
      }

      z_fraction_width.downto(0) do |i|
        stage2[i].on {
          if i == z_fraction_width then
            Constant :zi_h           => Unsigned(d_fraction_width+1)                <= 0
            Constant :zi_l           => Unsigned(s_fraction_width-2)                <= 0
            Constant :exponent_a_ext => Unsigned(q_exponent_width-a_exponent_width) <= 0
            Wire     :exponent_a_in  => Unsigned(q_exponent_width)                  <= BitConcat(exponent_a_ext, stage1_a_exponent)
            Wire     :exponent_a_d   => Signed(  q_exponent_width)                  <= exponent_a_in - a_exponent_offset
            Constant :exponent_b_ext => Unsigned(q_exponent_width-b_exponent_width) <= 0
            Wire     :exponent_b_in  => Unsigned(q_exponent_width)                  <= BitConcat(exponent_b_ext, stage1_b_exponent)
            Wire     :exponent_b_d   => Signed(  q_exponent_width)                  <= exponent_b_in - b_exponent_offset
            stage2_zi[i]        <= BitConcat(zi_h, stage1_a_fraction, zi_l)
            stage2_di[i]        <= stage1_b_fraction
            stage2_exponent[i]  <= exponent_a_d  - exponent_b_d
            stage2_sign[i]      <= stage1_a_sign ^ stage1_b_sign

            Wire     :exponent_a_is_all_0 => Unsigned(0) <=   stage1_a_exponent_is_all_0
            Wire     :exponent_a_is_all_1 => Unsigned(0) <=  (stage1_a_exponent == a_exponent_all_1)
            Wire     :fraction_a_is_all_0 => Unsigned(0) <=   stage1_a_fraction_is_all_0
            Wire     :fraction_a_is_not_0 => Unsigned(0) <= !(stage1_a_fraction_is_all_0)
            stage2_a_is_zero[i] <= exponent_a_is_all_0 & fraction_a_is_all_0
            stage2_a_is_inf[i]  <= exponent_a_is_all_1 & fraction_a_is_all_0
            stage2_a_is_nan[i]  <= exponent_a_is_all_1 & fraction_a_is_not_0
            
            Wire     :exponent_b_is_all_0 => Unsigned(0) <=   stage1_b_exponent_is_all_0
            Wire     :exponent_b_is_all_1 => Unsigned(0) <=  (stage1_b_exponent == b_exponent_all_1)
            Wire     :fraction_b_is_all_0 => Unsigned(0) <=   stage1_b_fraction_is_all_0
            Wire     :fraction_b_is_not_0 => Unsigned(0) <= !(stage1_b_fraction_is_all_0)
            stage2_b_is_zero[i] <= exponent_b_is_all_0 & fraction_b_is_all_0
            stage2_b_is_inf[i]  <= exponent_b_is_all_1 & fraction_b_is_all_0
            stage2_b_is_nan[i]  <= exponent_b_is_all_1 & fraction_b_is_not_0
            
            Goto stage2[i-1]
          else
            Wire     :pr => Unsigned(d_fraction_width+1) <= BitSel(stage2_zi[i+1], stage2_pr_high, stage2_pr_low)
            Wire     :sb => Unsigned(d_fraction_width+1) <= Sub(pr, stage2_di[i+1])
            Wire     :m0 => Unsigned(d_fraction_width)   <= BitSel(sb, stage2_mx_high, stage2_mx_low)
            Wire     :m1 => Unsigned(d_fraction_width)   <= BitSel(pr, stage2_mx_high, stage2_mx_low)
            Wire     :ms => Unsigned(1)                  <= BitSel(sb, stage2_ms_pos , stage2_ms_pos)
            Wire     :mx => Unsigned(d_fraction_width)   <= Select(ms, m0, m1)
            Wire     :zl => Unsigned(z_fraction_width-1) <= BitSel(stage2_zi[i+1], stage2_zl_high, stage2_zl_low)
            Wire     :zb => Unsigned(1)                  <= BitInv(ms)
            stage2_zi[i]        <= BitConcat(mx, zl, zb)
            stage2_di[i]        <= stage2_di[i+1]
            stage2_sign[i]      <= stage2_sign[i+1]
            stage2_a_is_zero[i] <= stage2_a_is_zero[i+1]
            stage2_a_is_inf[i]  <= stage2_a_is_inf[i+1]
            stage2_a_is_nan[i]  <= stage2_a_is_nan[i+1]
            stage2_b_is_zero[i] <= stage2_b_is_zero[i+1]
            stage2_b_is_inf[i]  <= stage2_b_is_inf[i+1]
            stage2_b_is_nan[i]  <= stage2_b_is_nan[i+1]
            if (i > 0) then
              stage2_exponent[i]  <= stage2_exponent[i+1]
              Goto stage2[i-1]
            else
              stage2_exponent[i]  <= stage2_exponent[i+1] + o_exponent_offset
              Goto stage3
            end
          end
        }
      end

      stage3.on {
        Wire     :z_msb  => Unsigned(1) <= BitSel(stage2_zi[0], s_fraction_width-2)
        stage3_fraction  <= Select(z_msb,
                                   BitConcat(BitSel(stage2_zi[0], s_fraction_width-3, 0), To_Unsigned(3, 2)),
                                   BitConcat(BitSel(stage2_zi[0], s_fraction_width-2, 0), To_Unsigned(1, 1)))
        stage3_exponent  <= stage2_exponent[ 0] - ~(z_msb)
        stage3_sign      <= stage2_sign[     0]
        stage3_a_is_zero <= stage2_a_is_zero[0]
        stage3_a_is_inf  <= stage2_a_is_inf[ 0]
        stage3_a_is_nan  <= stage2_a_is_nan[ 0]
        stage3_b_is_zero <= stage2_b_is_zero[0]
        stage3_b_is_inf  <= stage2_b_is_inf[ 0]
        stage3_b_is_nan  <= stage2_b_is_nan[ 0]
      }

      stage4.on {
        Constant :fraction_all_1      => Unsigned(s_fraction_width-3) <= (0..s_fraction_width-4).to_a.inject(0){|d,n| d = d + 2**n}
        Wire     :fraction_data       => Unsigned(s_fraction_width-3) <= BitSel(stage3_fraction, s_fraction_width-1, 3)
        Wire     :s_least             => Unsigned(1)                  <= BitSel(stage3_fraction, 3)
        Wire     :s_guard             => Unsigned(1)                  <= BitSel(stage3_fraction, 2)
        Wire     :s_round             => Unsigned(1)                  <= BitSel(stage3_fraction, 1)
        Wire     :s_sticky            => Unsigned(1)                  <= BitSel(stage3_fraction, 0)
        Wire     :increment           => Unsigned(1)                  <= s_guard & (s_least | s_round | s_sticky)
        stage4_fraction  <= fraction_data   + increment
        stage4_exponent  <= stage3_exponent + (increment & (fraction_data == fraction_all_1))
        stage4_sign      <= stage3_sign
        stage4_a_is_zero <= stage3_a_is_zero
        stage4_a_is_inf  <= stage3_a_is_inf
        stage4_a_is_nan  <= stage3_a_is_nan
        stage4_b_is_zero <= stage3_b_is_zero
        stage4_b_is_inf  <= stage3_b_is_inf
        stage4_b_is_nan  <= stage3_b_is_nan
      }
      
      stage5.on {
        Constant :zero_exponent      => Unsigned(o_exponent_width) <= 0
        Constant :zero_fraction      => Unsigned(o_fraction_width) <= 0
        Constant :inf_exponent       => Unsigned(o_exponent_width) <= 2**o_exponent_width-1
        Constant :inf_fraction       => Unsigned(o_fraction_width) <= 0
        Constant :nan_exponent       => Unsigned(o_exponent_width) <= 2**o_exponent_width-1
        Constant :nan_fraction       => Unsigned(o_fraction_width) <= 2**(o_fraction_width-2)
        Constant :nan_sign           => Unsigned(0)                <= 0

        Constant :exponent_min       => Signed(q_exponent_width)   <= 0
        Constant :exponent_max       => Signed(q_exponent_width)   <= 2**(o_exponent_width)-1
        Wire     :exp_natural        => Unsigned(0)                <= (stage4_exponent >  exponent_min)
        Wire     :exp_underflow      => Unsigned(0)                <= !exp_natural
        Wire     :exp_overflow       => Unsigned(0)                <= (stage4_exponent >= exponent_max)

        Wire     :exponent_in        => Unsigned(o_exponent_width) <= BitSel(stage4_exponent, o_exponent_width-1, 0)
        Wire     :fraction_in        => Unsigned(o_fraction_width) <= BitSel(stage4_fraction, o_fraction_width-1, 0)

        Wire     :exponent_i1        => Unsigned(o_exponent_width) <= Select(exp_overflow , exponent_in, inf_exponent )
        Wire     :fraction_i1        => Unsigned(o_fraction_width) <= Select(exp_overflow , fraction_in, inf_fraction )

        Wire     :exponent_di        => Unsigned(o_exponent_width) <= Select(exp_underflow, exponent_i1, zero_exponent)
        Wire     :fraction_di        => Unsigned(o_fraction_width) <= Select(exp_underflow, fraction_i1, zero_fraction)

        Wire     :a_is_zero          => Unsigned(0)                <= stage4_a_is_zero
        Wire     :a_is_inf           => Unsigned(0)                <= stage4_a_is_inf
        Wire     :a_is_nan           => Unsigned(0)                <= stage4_a_is_nan
        Wire     :a_is_norm          => Unsigned(0)                <= !(a_is_zero | a_is_inf | a_is_nan)

        Wire     :b_is_zero          => Unsigned(0)                <= stage4_b_is_zero
        Wire     :b_is_inf           => Unsigned(0)                <= stage4_b_is_inf
        Wire     :b_is_nan           => Unsigned(0)                <= stage4_b_is_nan
        Wire     :b_is_norm          => Unsigned(0)                <= !(b_is_zero | b_is_inf | b_is_nan)

        Wire     :set_zero           => Unsigned(0)                <= (a_is_zero & b_is_inf ) | (a_is_zero & b_is_norm) | (a_is_norm & b_is_inf )
        Wire     :set_inf            => Unsigned(0)                <= (a_is_inf  & b_is_zero) | (a_is_inf  & b_is_norm) | (a_is_norm & b_is_zero)
        Wire     :set_norm           => Unsigned(0)                <= (a_is_norm & b_is_norm)
        Wire     :set_nan            => Unsigned(0)                <= (a_is_zero & b_is_zero) | (a_is_zero & b_is_nan ) |
                                                                      (a_is_inf  & b_is_inf ) | (a_is_inf  & b_is_nan ) |
                                                                      (a_is_nan) |
                                                                      (a_is_norm & b_is_nan )

        Wire     :fraction_o0        => Unsigned(o_fraction_width) <= Select(set_norm, nan_fraction, fraction_di  )
        Wire     :exponent_o0        => Unsigned(o_exponent_width) <= Select(set_norm, nan_exponent, exponent_di  )

        Wire     :fraction_o1        => Unsigned(o_fraction_width) <= Select(set_inf , fraction_o0 , inf_fraction )
        Wire     :exponent_o1        => Unsigned(o_exponent_width) <= Select(set_inf , exponent_o0 , inf_exponent )

        Wire     :sign_o             => Unsigned(1)                <= Select(set_nan , stage4_sign , nan_sign     )
        Wire     :fraction_o         => Unsigned(o_fraction_width) <= Select(set_zero, fraction_o1 , zero_fraction)
        Wire     :exponent_o         => Unsigned(o_exponent_width) <= Select(set_zero, exponent_o1 , zero_exponent)

        Wire     :result             => Unsigned(o_width)          <= BitConcat(sign_o, exponent_o, fraction_o)
        z_out   <= result
        z_valid <= To_Unsigned(1,1)
      }
    end
  end
end

puts design.to_exp("")
