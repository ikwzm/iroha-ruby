require_relative '../lib/iroha/builder/simple'

include Iroha::Builder::Simple

design = IDesign :design do
  IModule :fmul do
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

      Start     :start
      ExtInput  :i_valid             => 0

      ExtOutput :z_out               => o_width

      Constant  :a_exponent_offset   => Unsigned(a_exponent_width) <= 2**(a_exponent_width-1)-1
      Constant  :a_exponent_all_0    => Unsigned(a_exponent_width) <= 0
      Constant  :a_exponent_all_1    => Unsigned(a_exponent_width) <= (0..a_exponent_width-1).to_a.inject(0){|d,n| d = d + 2**n}
      Constant  :a_fraction_all_0    => Unsigned(a_fraction_width) <= 0
      ExtInput  :a_in                => a_width

      Constant  :b_exponent_offset   => Unsigned(b_exponent_width) <= 2**(b_exponent_width-1)-1
      Constant  :b_exponent_all_0    => Unsigned(b_exponent_width) <= 0
      Constant  :b_exponent_all_1    => Unsigned(b_exponent_width) <= (0..b_exponent_width-1).to_a.inject(0){|d,n| d = d + 2**n}
      Constant  :b_fraction_all_0    => Unsigned(b_fraction_width) <= 0
      ExtInput  :b_in                => b_width

      Constant  :o_exponent_offset   => Unsigned(o_exponent_width) <= 2**(o_exponent_width-1)-1
      Constant  :o_exponent_all_1    => Unsigned(o_exponent_width) <= (0..o_exponent_width-1).to_a.inject(0){|d,n| d = d + 2**n}

      IStage    :stage1, :stage2, :stage3, :stage4, :stage5

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

      mul_fraction_width = (a_fraction_width+1) + (b_fraction_width+1)
      i_exponent_width   = (a_exponent_width > b_exponent_width) ? a_exponent_width : b_exponent_width
      mul_exponent_width = (o_exponent_width > i_exponent_width) ? o_exponent_width + 2 : i_exponent_width + 2
      Register  :stage2_fraction            => Unsigned(mul_fraction_width)
      Register  :stage2_exponent            => Signed(mul_exponent_width)
      Register  :stage2_sign                => Unsigned(0)
      Register  :stage2_a_is_zero           => Unsigned(0)
      Register  :stage2_a_is_inf            => Unsigned(0)
      Register  :stage2_a_is_nan            => Unsigned(0)
      Register  :stage2_b_is_zero           => Unsigned(0)
      Register  :stage2_b_is_inf            => Unsigned(0)
      Register  :stage2_b_is_nan            => Unsigned(0)

      Register  :stage3_fraction            => Unsigned(o_fraction_width)
      Register  :stage3_exponent            => Signed(mul_exponent_width)
      Register  :stage3_sign                => Unsigned(0)
      Register  :stage3_guard               => Unsigned(0)
      Register  :stage3_round               => Unsigned(0)
      Register  :stage3_sticky              => Unsigned(0)
      Register  :stage3_a_is_zero           => Unsigned(0)
      Register  :stage3_a_is_inf            => Unsigned(0)
      Register  :stage3_a_is_nan            => Unsigned(0)
      Register  :stage3_b_is_zero           => Unsigned(0)
      Register  :stage3_b_is_inf            => Unsigned(0)
      Register  :stage3_b_is_nan            => Unsigned(0)

      Register  :stage4_fraction            => Unsigned(o_fraction_width)
      Register  :stage4_exponent            => Signed(mul_exponent_width)
      Register  :stage4_sign                => Unsigned(0)
      Register  :stage4_a_is_zero           => Unsigned(0)
      Register  :stage4_a_is_inf            => Unsigned(0)
      Register  :stage4_a_is_nan            => Unsigned(0)
      Register  :stage4_b_is_zero           => Unsigned(0)
      Register  :stage4_b_is_inf            => Unsigned(0)
      Register  :stage4_b_is_nan            => Unsigned(0)

      stage1.on {
        start  <= i_valid

        Constant  :a_fraction_low_pos  => Unsigned(32) <= 0
        Constant  :a_fraction_high_pos => Unsigned(32) <= a_fraction_width-1
        Constant  :a_exponent_low_pos  => Unsigned(32) <= a_fraction_width
        Constant  :a_exponent_high_pos => Unsigned(32) <= a_fraction_width + a_exponent_width-1
        Constant  :a_sign_pos          => Unsigned(32) <= a_fraction_width + a_exponent_width
        Wire      :a_data_in           => Unsigned(a_width)
        Wire      :a_exponent_in       => Unsigned(a_exponent_width)
        Wire      :a_fraction_in       => Unsigned(a_fraction_width)
        Wire      :a_sign_in           => Unsigned(0)
        Wire      :a_exponent_zero     => Unsigned(0)
        Wire      :a_fraction_msb      => Unsigned(1)

        a_data_in     <= a_in
        a_exponent_in <= BitSel(a_data_in, a_exponent_high_pos, a_exponent_low_pos)
        a_fraction_in <= BitSel(a_data_in, a_fraction_high_pos, a_fraction_low_pos)
        a_sign_in     <= BitSel(a_data_in, a_sign_pos         , a_sign_pos        )

        a_exponent_zero            <= (a_exponent_in == a_exponent_all_0)
        a_fraction_msb             <= BitInv(a_exponent_zero)
        stage1_a_fraction          <= BitConcat(a_fraction_msb, a_fraction_in)
        stage1_a_exponent          <= a_exponent_in
        stage1_a_sign              <= a_sign_in
        stage1_a_exponent_is_all_0 <= a_exponent_zero
        stage1_a_fraction_is_all_0 <= (a_fraction_in == a_fraction_all_0)

        Constant  :b_fraction_low_pos  => Unsigned(32) <= 0
        Constant  :b_fraction_high_pos => Unsigned(32) <= b_fraction_width-1
        Constant  :b_exponent_low_pos  => Unsigned(32) <= b_fraction_width
        Constant  :b_exponent_high_pos => Unsigned(32) <= b_fraction_width + b_exponent_width-1
        Constant  :b_sign_pos          => Unsigned(32) <= b_fraction_width + b_exponent_width
        Wire      :b_data_in           => Unsigned(b_width)
        Wire      :b_exponent_in       => Unsigned(b_exponent_width)
        Wire      :b_fraction_in       => Unsigned(b_fraction_width)
        Wire      :b_sign_in           => Unsigned(0)
        Wire      :b_exponent_zero     => Unsigned(0)
        Wire      :b_fraction_msb      => Unsigned(1)

        b_data_in     <= b_in
        b_exponent_in <= BitSel(b_data_in, b_exponent_high_pos, b_exponent_low_pos)
        b_fraction_in <= BitSel(b_data_in, b_fraction_high_pos, b_fraction_low_pos)
        b_sign_in     <= BitSel(b_data_in, b_sign_pos         , b_sign_pos        )

        b_exponent_zero            <= (b_exponent_in == b_exponent_all_0)
        b_fraction_msb             <= BitInv(b_exponent_zero)
        stage1_b_fraction          <= BitConcat(b_fraction_msb, b_fraction_in)
        stage1_b_exponent          <= b_exponent_in
        stage1_b_sign              <= b_sign_in
        stage1_b_exponent_is_all_0 <= b_exponent_zero
        stage1_b_fraction_is_all_0 <= (b_fraction_in == b_fraction_all_0)
        Goto stage2
      }

      stage2.on {
        Constant :exponent_a_ext     => Unsigned(mul_exponent_width-a_exponent_width) <= 0
        Wire     :exponent_a_in      => Unsigned(mul_exponent_width)
        Wire     :exponent_a_d       => Signed(mul_exponent_width)
        Constant :exponent_b_ext     => Unsigned(mul_exponent_width-b_exponent_width) <= 0
        Wire     :exponent_b_in      => Unsigned(mul_exponent_width)
        Wire     :exponent_b_d       => Signed(mul_exponent_width)
        exponent_a_in    <= BitConcat(exponent_a_ext, stage1_a_exponent)
        exponent_b_in    <= BitConcat(exponent_b_ext, stage1_b_exponent)
        exponent_a_d     <= exponent_a_in - a_exponent_offset
        exponent_b_d     <= exponent_b_in - b_exponent_offset
        stage2_exponent  <= exponent_a_d  + exponent_b_d
        stage2_fraction  <= stage1_a_fraction * stage1_b_fraction
        stage2_sign      <= stage1_a_sign     ^ stage1_b_sign

        Wire     :exponent_a_is_all_0 => Unsigned(0)
        Wire     :exponent_a_is_all_1 => Unsigned(0)
        Wire     :fraction_a_is_all_0 => Unsigned(0)
        Wire     :fraction_a_is_not_0 => Unsigned(0)
        exponent_a_is_all_0 <= stage1_a_exponent_is_all_0
        exponent_a_is_all_1 <= (stage1_a_exponent == a_exponent_all_1)
        fraction_a_is_not_0 <= BitInv(stage1_a_fraction_is_all_0)
        fraction_a_is_all_0 <= stage1_a_fraction_is_all_0
        stage2_a_is_zero    <= BitAnd(exponent_a_is_all_0, fraction_a_is_all_0)
        stage2_a_is_inf     <= BitAnd(exponent_a_is_all_1, fraction_a_is_all_0)
        stage2_a_is_nan     <= BitAnd(exponent_a_is_all_1, fraction_a_is_not_0)
        
        Wire     :exponent_b_is_all_0 => Unsigned(0)
        Wire     :exponent_b_is_all_1 => Unsigned(0)
        Wire     :fraction_b_is_all_0 => Unsigned(0)
        Wire     :fraction_b_is_not_0 => Unsigned(0)
        exponent_b_is_all_0 <= stage1_b_exponent_is_all_0
        exponent_b_is_all_1 <= (stage1_b_exponent == b_exponent_all_1)
        fraction_b_is_not_0 <= BitInv(stage1_b_fraction_is_all_0)
        fraction_b_is_all_0 <= stage1_b_fraction_is_all_0
        stage2_b_is_zero    <= BitAnd(exponent_b_is_all_0, fraction_b_is_all_0)
        stage2_b_is_inf     <= BitAnd(exponent_b_is_all_1, fraction_b_is_all_0)
        stage2_b_is_nan     <= BitAnd(exponent_b_is_all_1, fraction_b_is_not_0)
        
        Goto stage3
      }

      stage3.on {
        Constant  :mul_fraction_msb_pos       => Unsigned(32) <= mul_fraction_width-1
        Wire      :mul_fraction_msb           => Unsigned(1)
        Wire      :mul_exponent               => Signed(mul_exponent_width)
        mul_fraction_msb <= BitSel(stage2_fraction, mul_fraction_msb_pos, mul_fraction_msb_pos)
        mul_exponent     <= stage2_exponent + mul_fraction_msb
        
        Constant  :mul_fraction_0_high        => Unsigned(32) <= mul_fraction_width-3
        Constant  :mul_fraction_0_low         => Unsigned(32) <= mul_fraction_width-o_fraction_width-2
        Constant  :mul_fraction_0_guard_pos   => Unsigned(32) <= mul_fraction_width-o_fraction_width-3
        Constant  :mul_fraction_0_round_pos   => Unsigned(32) <= mul_fraction_width-o_fraction_width-4
        Constant  :mul_fraction_0_sticky_high => Unsigned(32) <= mul_fraction_width-o_fraction_width-5
        Constant  :mul_fraction_0_sticky_low  => Unsigned(32) <= 0
        Wire      :mul_0_fraction             => Unsigned(o_fraction_width)
        Wire      :mul_0_guard                => Unsigned(0)
        Wire      :mul_0_round                => Unsigned(0)
        Wire      :mul_0_sticky               => Unsigned(0)
        Wire      :mul_0_sticky_not           => Unsigned(0)
        Wire      :mul_0_sticky_data          => Unsigned(mul_fraction_width-o_fraction_width-4)
        Constant  :mul_0_sticky_zero          => Unsigned(mul_fraction_width-o_fraction_width-4) <= 0
        mul_0_fraction    <= BitSel(stage2_fraction, mul_fraction_0_high       , mul_fraction_0_low       )
        mul_0_guard       <= BitSel(stage2_fraction, mul_fraction_0_guard_pos  , mul_fraction_0_guard_pos )
        mul_0_round       <= BitSel(stage2_fraction, mul_fraction_0_round_pos  , mul_fraction_0_round_pos )
        mul_0_sticky_data <= BitSel(stage2_fraction, mul_fraction_0_sticky_high, mul_fraction_0_sticky_low)
        mul_0_sticky_not  <= (mul_0_sticky_data == mul_0_sticky_zero)
        mul_0_sticky      <= BitInv(mul_0_sticky_not)
        
        Constant  :mul_fraction_1_high        => Unsigned(32) <= mul_fraction_width-2
        Constant  :mul_fraction_1_low         => Unsigned(32) <= mul_fraction_width-o_fraction_width-1
        Constant  :mul_fraction_1_guard_pos   => Unsigned(32) <= mul_fraction_width-o_fraction_width-2
        Constant  :mul_fraction_1_round_pos   => Unsigned(32) <= mul_fraction_width-o_fraction_width-3
        Constant  :mul_fraction_1_sticky_high => Unsigned(32) <= mul_fraction_width-o_fraction_width-4
        Constant  :mul_fraction_1_sticky_low  => Unsigned(32) <= 0
        Wire      :mul_1_fraction             => Unsigned(o_fraction_width)
        Wire      :mul_1_guard                => Unsigned(0)
        Wire      :mul_1_round                => Unsigned(0)
        Wire      :mul_1_sticky               => Unsigned(0)
        Wire      :mul_1_sticky_not           => Unsigned(0)
        Wire      :mul_1_sticky_data          => Unsigned(mul_fraction_width-o_fraction_width-3)
        Constant  :mul_1_sticky_zero          => Unsigned(mul_fraction_width-o_fraction_width-3) <= 0
        mul_1_fraction    <= BitSel(stage2_fraction, mul_fraction_1_high       , mul_fraction_1_low       )
        mul_1_guard       <= BitSel(stage2_fraction, mul_fraction_1_guard_pos  , mul_fraction_1_guard_pos )
        mul_1_round       <= BitSel(stage2_fraction, mul_fraction_1_round_pos  , mul_fraction_1_round_pos )
        mul_1_sticky_data <= BitSel(stage2_fraction, mul_fraction_1_sticky_high, mul_fraction_1_sticky_low)
        mul_1_sticky_not  <= (mul_1_sticky_data == mul_1_sticky_zero)
        mul_1_sticky      <= BitInv(mul_1_sticky_not)

        stage3_exponent   <= mul_exponent + o_exponent_offset
        stage3_fraction   <= Select(mul_fraction_msb, mul_0_fraction, mul_1_fraction)
        stage3_guard      <= Select(mul_fraction_msb, mul_0_guard   , mul_1_guard   )
        stage3_round      <= Select(mul_fraction_msb, mul_0_round   , mul_1_round   )
        stage3_sticky     <= Select(mul_fraction_msb, mul_0_sticky  , mul_1_sticky  )
        stage3_sign       <= stage2_sign
        stage3_a_is_zero  <= stage2_a_is_zero
        stage3_a_is_inf   <= stage2_a_is_inf
        stage3_a_is_nan   <= stage2_a_is_nan
        stage3_b_is_zero  <= stage2_b_is_zero
        stage3_b_is_inf   <= stage2_b_is_inf
        stage3_b_is_nan   <= stage2_b_is_nan
        Goto stage4
      }

      stage4.on {
        Constant :fraction_lsb_pos   => Unsigned(32) <= 0
        Wire     :fraction_lsb       => Unsigned(0)
        Wire     :increment_cond_0   => Unsigned(0)
        Wire     :increment_cond_1   => Unsigned(0)
        Wire     :fraction_increment => Unsigned(1)
        Constant :fraction_all_1     => Unsigned(o_fraction_width) <= 2**o_fraction_width-1
        Wire     :fraction_is_all_1  => Unsigned(1)
        Wire     :exponent_increment => Unsigned(1)
        fraction_lsb       <= BitSel(stage3_fraction, fraction_lsb_pos, fraction_lsb_pos)
        increment_cond_0   <= BitOr(fraction_lsb    , stage3_round)
        increment_cond_1   <= BitOr(increment_cond_0, stage3_sticky)
        fraction_increment <= BitAnd(stage3_guard, increment_cond_1)
        fraction_is_all_1  <= (stage3_fraction == fraction_all_1)
        exponent_increment <= BitAnd(fraction_increment, fraction_is_all_1)
        stage4_fraction    <= stage3_fraction + fraction_increment
        stage4_exponent    <= stage3_exponent + exponent_increment
        stage4_sign        <= stage3_sign
        stage4_a_is_zero   <= stage3_a_is_zero
        stage4_a_is_inf    <= stage3_a_is_inf
        stage4_a_is_nan    <= stage3_a_is_nan
        stage4_b_is_zero   <= stage3_b_is_zero
        stage4_b_is_inf    <= stage3_b_is_inf
        stage4_b_is_nan    <= stage3_b_is_nan
        Goto stage5
      }
      
      stage5.on {
        Constant :zero_exponent    => Unsigned(o_exponent_width) <= 0
        Constant :zero_fraction    => Unsigned(o_fraction_width) <= 0
        Constant :inf_exponent     => Unsigned(o_exponent_width) <= 2**o_exponent_width-1
        Constant :inf_fraction     => Unsigned(o_fraction_width) <= 0
        Constant :nan_exponent     => Unsigned(o_exponent_width) <= 2**o_exponent_width-1
        Constant :nan_fraction     => Unsigned(o_fraction_width) <= 2**(o_fraction_width-2)
        
        Constant :mul_exponent_msb => Unsigned(32) <= mul_exponent_width-1
        Constant :mul_exponent_min => Signed(mul_exponent_width) <= 0
        Constant :mul_exponent_max => Signed(mul_exponent_width) <= 2**(o_exponent_width)-1
        Wire     :exp_natural      => Unsigned(0)
        Wire     :exp_underflow    => Unsigned(0)
        Wire     :exp_overflow     => Unsigned(0)
        exp_natural   <= (stage4_exponent >  mul_exponent_min)
        exp_underflow <= BitInv(exp_natural)
        exp_overflow  <= (stage4_exponent >= mul_exponent_max)

        Wire     :fraction_in      => Unsigned(o_fraction_width)
        Wire     :exponent_in      => Unsigned(o_exponent_width)
        Constant :exponent_msb     => Unsigned(32) <= o_exponent_width-1
        Constant :exponent_lsb     => Unsigned(32) <= 0
        fraction_in <= stage4_fraction
        exponent_in <= BitSel(stage4_exponent, exponent_msb, exponent_lsb)

        Wire     :fraction_i1      => Unsigned(o_fraction_width)
        Wire     :exponent_i1      => Unsigned(o_exponent_width)
        fraction_i1 <= Select(exp_overflow , fraction_in, inf_fraction )
        exponent_i1 <= Select(exp_overflow , exponent_in, inf_exponent )

        Wire     :fraction_di      => Unsigned(o_fraction_width)
        Wire     :exponent_di      => Unsigned(o_exponent_width)
        fraction_di <= Select(exp_underflow, fraction_i1, zero_fraction)
        exponent_di <= Select(exp_underflow, exponent_i1, zero_exponent)

        Wire     :a_is_norm_0      => Unsigned(0)
        Wire     :a_is_norm_1      => Unsigned(0)
        Wire     :a_is_norm        => Unsigned(0)
        Wire     :a_is_zero        => Unsigned(0)
        Wire     :a_is_inf         => Unsigned(0)
        Wire     :a_is_nan         => Unsigned(0)
        a_is_norm_0 <= BitOr(stage4_a_is_inf , stage4_a_is_nan)
        a_is_norm_1 <= BitOr(stage4_a_is_zero, a_is_norm_0    )
        a_is_norm   <= BitInv(a_is_norm_1)
        a_is_zero   <= stage4_a_is_zero
        a_is_inf    <= stage4_a_is_inf
        a_is_nan    <= stage4_a_is_nan

        Wire     :b_is_norm_0      => Unsigned(0)
        Wire     :b_is_norm_1      => Unsigned(0)
        Wire     :b_is_norm        => Unsigned(0)
        Wire     :b_is_zero        => Unsigned(0)
        Wire     :b_is_inf         => Unsigned(0)
        Wire     :b_is_nan         => Unsigned(0)
        b_is_norm_0 <= BitOr(stage4_b_is_inf , stage4_b_is_nan)
        b_is_norm_1 <= BitOr(stage4_b_is_zero, b_is_norm_0    )
        b_is_norm   <= BitInv(b_is_norm_1)
        b_is_zero   <= stage4_b_is_zero
        b_is_inf    <= stage4_b_is_inf
        b_is_nan    <= stage4_b_is_nan

        Wire     :set_zero_0       => Unsigned(0)
        Wire     :set_zero_1       => Unsigned(0)
        Wire     :set_zero_2       => Unsigned(0)
        Wire     :set_zero_3       => Unsigned(0)
        Wire     :set_zero         => Unsigned(0)
        set_zero_0 <= BitAnd(a_is_zero, b_is_norm)
        set_zero_1 <= BitAnd(a_is_norm, b_is_zero)
        set_zero_2 <= BitAnd(a_is_zero, b_is_zero)
        set_zero_3 <= BitOr(set_zero_0, set_zero_1)
        set_zero   <= BitOr(set_zero_2, set_zero_3)

        Wire     :set_inf_0        => Unsigned(0)
        Wire     :set_inf_1        => Unsigned(0)
        Wire     :set_inf_2        => Unsigned(0)
        Wire     :set_inf_3        => Unsigned(0)
        Wire     :set_inf          => Unsigned(0)
        set_inf_0  <= BitAnd(a_is_inf , b_is_inf )
        set_inf_1  <= BitAnd(a_is_norm, b_is_inf )
        set_inf_2  <= BitAnd(a_is_inf , b_is_norm)
        set_inf_3  <= BitOr(set_inf_0 , set_inf_1)
        set_inf    <= BitOr(set_inf_2 , set_inf_3)

        Wire     :set_norm         => Unsigned(0)
        set_norm   <= BitAnd(a_is_norm, b_is_norm)
        
        Wire     :fraction_o0      => Unsigned(o_fraction_width)
        Wire     :exponent_o0      => Unsigned(o_exponent_width)
        fraction_o0 <= Select(set_norm , nan_fraction, fraction_di)
        exponent_o0 <= Select(set_norm , nan_exponent, exponent_di)

        Wire     :fraction_o1      => Unsigned(o_fraction_width)
        Wire     :exponent_o1      => Unsigned(o_exponent_width)
        fraction_o1 <= Select(set_inf , fraction_o0, inf_fraction )
        exponent_o1 <= Select(set_inf , exponent_o0, inf_exponent )

        Wire     :fraction_o       => Unsigned(o_fraction_width)
        Wire     :exponent_o       => Unsigned(o_exponent_width)
        fraction_o  <= Select(set_zero, fraction_o1, zero_fraction)
        exponent_o  <= Select(set_zero, exponent_o1, zero_exponent)

        Wire     :result           => Unsigned(o_width)
        result <= BitConcat(stage4_sign, exponent_o, fraction_o)
        z_out  <= result
      }
    end
  end
end

puts design.to_exp("")
