require_relative '../lib/iroha/builder/simple'

include Iroha::Builder::Simple

design = IDesign :design do
  IModule :fadd do
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

      Start          :start
      ExtInput       :i_valid  => Unsigned(0)
      ExtInput       :a_in     => Unsigned(a_width)
      ExtInput       :b_in     => Unsigned(b_width)
      ExtInput       :sub      => Unsigned(0)
      ExtOutput      :z_out    => Unsigned(o_width)
      ExtOutput      :z_valid  => Unsigned(0) <= 0
      Constant       :done     => Unsigned(0) <= 1

      i_width          = [a_width         , b_width         ].max
      i_fraction_width = [a_fraction_width, b_fraction_width].max
      i_exponent_width = [a_exponent_width, b_exponent_width].max

      t_fraction_width = [i_fraction_width, o_fraction_width].max + 5
      t_exponent_width = [i_exponent_width, o_exponent_width].max
      s_fraction_width = t_fraction_width + i_fraction_width + 1
      s_exponent_width = t_exponent_width

      Constant  :a_exponent_offset   => Unsigned(a_exponent_width) <= 2**(a_exponent_width-1)-1
      Constant  :b_exponent_offset   => Unsigned(b_exponent_width) <= 2**(b_exponent_width-1)-1
      
      Constant  :i_exponent_offset   => Unsigned(o_exponent_width) <= 2**(i_exponent_width-1)-1
      Constant  :i_exponent_all_0    => Unsigned(i_exponent_width) <= 0
      Constant  :i_exponent_all_1    => Unsigned(i_exponent_width) <= (0..i_exponent_width-1).to_a.inject(0){|d,n| d = d + 2**n}
      Constant  :i_fraction_all_0    => Unsigned(i_fraction_width) <= 0

      IStage    :stage1, :stage2, :stage3, :stage4, :stage5, :stage6, :stage7, :stage8

      Register  :stage1_a_fraction   => Unsigned(i_fraction_width)
      Register  :stage1_a_exponent   => Unsigned(i_exponent_width)
      Register  :stage1_a_sign       => Unsigned(0)
      Register  :stage1_b_fraction   => Unsigned(i_fraction_width)
      Register  :stage1_b_exponent   => Unsigned(i_exponent_width)
      Register  :stage1_b_sign       => Unsigned(0)
      Register  :stage1_sub          => Unsigned(0)

      Register  :stage2_sub          => Unsigned(0)
      Register  :stage2_b_gt_a       => Unsigned(0)
      Register  :stage2_l_fraction   => Unsigned(i_fraction_width+1)
      Register  :stage2_l_exponent   => Unsigned(i_exponent_width  )
      Register  :stage2_l_sign       => Unsigned(0)
      Register  :stage2_s_fraction   => Unsigned(i_fraction_width+1)
      Register  :stage2_s_exponent   => Unsigned(i_exponent_width  )
      Register  :stage2_s_sign       => Unsigned(0)
      Register  :stage2_a_is_zero    => Unsigned(0)
      Register  :stage2_a_is_inf     => Unsigned(0)
      Register  :stage2_a_is_nan     => Unsigned(0)
      Register  :stage2_b_is_zero    => Unsigned(0)
      Register  :stage2_b_is_inf     => Unsigned(0)
      Register  :stage2_b_is_nan     => Unsigned(0)

      Register  :stage3_sub          => Unsigned(0)
      Register  :stage3_b_gt_a       => Unsigned(0)
      Register  :stage3_op_sub       => Unsigned(0)
      Register  :stage3_diff_exponent => Unsigned(i_exponent_width  )
      Register  :stage3_t_sign       => Unsigned(1)
      Register  :stage3_t_exponent   => Unsigned(t_exponent_width  )
      Register  :stage3_l_fraction   => Unsigned(i_fraction_width+1)
      Register  :stage3_s_fraction   => Unsigned(i_fraction_width+1)
      Register  :stage3_a_is_zero    => Unsigned(0)
      Register  :stage3_a_is_inf     => Unsigned(0)
      Register  :stage3_a_is_nan     => Unsigned(0)
      Register  :stage3_b_is_zero    => Unsigned(0)
      Register  :stage3_b_is_inf     => Unsigned(0)
      Register  :stage3_b_is_nan     => Unsigned(0)
      
      Register  :stage4_sub          => Unsigned(0)
      Register  :stage4_b_gt_a       => Unsigned(0)
      Register  :stage4_op_sub       => Unsigned(0)
      Register  :stage4_t_sign       => Unsigned(1)
      Register  :stage4_t_exponent   => Unsigned(t_exponent_width)
      Register  :stage4_l_fraction   => Unsigned(t_fraction_width)
      Register  :stage4_s_fraction   => Unsigned(t_fraction_width)
      Register  :stage4_a_is_zero    => Unsigned(0)
      Register  :stage4_a_is_inf     => Unsigned(0)
      Register  :stage4_a_is_nan     => Unsigned(0)
      Register  :stage4_b_is_zero    => Unsigned(0)
      Register  :stage4_b_is_inf     => Unsigned(0)
      Register  :stage4_b_is_nan     => Unsigned(0)
      
      Register  :stage5_sub          => Unsigned(0)
      Register  :stage5_b_gt_a       => Unsigned(0)
      Register  :stage5_t_sign       => Unsigned(1)
      Register  :stage5_t_exponent   => Unsigned(t_exponent_width)
      Register  :stage5_t_fraction   => Unsigned(t_fraction_width)
      Register  :stage5_a_is_zero    => Unsigned(0)
      Register  :stage5_a_is_inf     => Unsigned(0)
      Register  :stage5_a_is_nan     => Unsigned(0)
      Register  :stage5_b_is_zero    => Unsigned(0)
      Register  :stage5_b_is_inf     => Unsigned(0)
      Register  :stage5_b_is_nan     => Unsigned(0)
      
      Register  :stage6_sub          => Unsigned(0)
      Register  :stage6_b_gt_a       => Unsigned(0)
      Register  :stage6_t_sign       => Unsigned(1)
      Register  :stage6_t_exponent   => Signed(1+t_exponent_width)
      Register  :stage6_t_fraction   => Unsigned(t_fraction_width)
      Register  :stage6_a_is_zero    => Unsigned(0)
      Register  :stage6_a_is_inf     => Unsigned(0)
      Register  :stage6_a_is_nan     => Unsigned(0)
      Register  :stage6_b_is_zero    => Unsigned(0)
      Register  :stage6_b_is_inf     => Unsigned(0)
      Register  :stage6_b_is_nan     => Unsigned(0)
      
      Register  :stage7_sub          => Unsigned(0)
      Register  :stage7_b_gt_a       => Unsigned(0)
      Register  :stage7_t_sign       => Unsigned(1)
      Register  :stage7_t_exponent   => Signed(1+t_exponent_width)
      Register  :stage7_t_fraction   => Unsigned(o_fraction_width+1)
      Register  :stage7_a_is_zero    => Unsigned(0)
      Register  :stage7_a_is_inf     => Unsigned(0)
      Register  :stage7_a_is_nan     => Unsigned(0)
      Register  :stage7_b_is_zero    => Unsigned(0)
      Register  :stage7_b_is_inf     => Unsigned(0)
      Register  :stage7_b_is_nan     => Unsigned(0)
      
      stage1.on {
        start      <= i_valid
        stage1_sub <= sub

        Constant  :a_fraction_low_pos  => Unsigned(32)               <= 0
        Constant  :a_fraction_high_pos => Unsigned(32)               <= a_fraction_width-1
        Constant  :a_exponent_low_pos  => Unsigned(32)               <= a_fraction_width
        Constant  :a_exponent_high_pos => Unsigned(32)               <= a_fraction_width + a_exponent_width-1
        Constant  :a_sign_pos          => Unsigned(32)               <= a_fraction_width + a_exponent_width
        Wire      :a_data_in           => Unsigned(a_width)          <= a_in
        Wire      :a_fraction_in       => Unsigned(a_fraction_width) <= BitSel(a_data_in, a_fraction_high_pos, a_fraction_low_pos)
        Wire      :a_exponent_in       => Unsigned(a_exponent_width) <= BitSel(a_data_in, a_exponent_high_pos, a_exponent_low_pos)

        stage1_a_sign <= BitSel(a_data_in, a_sign_pos)
        if (i_fraction_width > a_fraction_width) then
          Constant :a_fraction_low     => Unsigned(i_fraction_width - a_fraction_width) <= 0
          stage1_a_fraction <= BitConcat(a_fraction_in, a_fraction_low)
        else
          stage1_a_fraction <= a_fraction_in
        end
        if (i_exponent_width > a_exponent_width) then
          Constant :a_exponent_diff    => Unsigned(i_exponent_width) <= (2**(i_exponent_width-1)-1) - (2**(a_exponent_width-1)-1)
          stage1_a_exponent <= a_exponent_in + a_exponent_diff
        else
          stage1_a_exponent <= a_exponent_in
        end

        Constant  :b_fraction_low_pos  => Unsigned(32)               <= 0
        Constant  :b_fraction_high_pos => Unsigned(32)               <= b_fraction_width-1
        Constant  :b_exponent_low_pos  => Unsigned(32)               <= b_fraction_width
        Constant  :b_exponent_high_pos => Unsigned(32)               <= b_fraction_width + b_exponent_width-1
        Constant  :b_sign_pos          => Unsigned(32)               <= b_fraction_width + b_exponent_width
        Wire      :b_data_in           => Unsigned(b_width)          <= b_in
        Wire      :b_fraction_in       => Unsigned(b_fraction_width) <= BitSel(b_data_in, b_fraction_high_pos, b_fraction_low_pos)
        Wire      :b_exponent_in       => Unsigned(b_exponent_width) <= BitSel(b_data_in, b_exponent_high_pos, b_exponent_low_pos)

        stage1_b_sign <= BitSel(b_data_in, b_sign_pos)
        if (i_fraction_width > b_fraction_width) then
          Constant :b_fraction_low     => Unsigned(i_fraction_width - b_fraction_width) <= 0
          stage1_b_fraction <= BitConcat(b_fraction_in, b_fraction_low)
        else
          stage1_b_fraction <= b_fraction_in
        end
        if (i_exponent_width > b_exponent_width) then
          Constant :b_exponent_diff    => Unsigned(i_exponent_width) <= (2**(i_exponent_width-1)-1) - (2**(b_exponent_width-1)-1)
          stage1_b_exponent <= b_exponent_in + b_exponent_diff
        else
          stage1_b_exponent <= b_exponent_in
        end
      }

      stage2.on {
        Wire      :a_exponent_is_all_1 => Unsigned(0)                  <= (stage1_a_exponent == i_exponent_all_1)
        Wire      :a_exponent_is_all_0 => Unsigned(0)                  <= (stage1_a_exponent == i_exponent_all_0)
        Wire      :a_fraction_is_all_0 => Unsigned(0)                  <= (stage1_a_fraction == i_fraction_all_0)
        Wire      :a_fraction_is_not_0 => Unsigned(0)                  <= !(a_fraction_is_all_0)
        Wire      :a_fraction_msb      => Unsigned(1)                  <= !(a_exponent_is_all_0)
        Wire      :a_fraction_in       => Unsigned(i_fraction_width+1) <= BitConcat(a_fraction_msb, stage1_a_fraction)
        Wire      :a_exponent_in       => Unsigned(i_exponent_width  ) <= stage1_a_exponent
        Wire      :a_sign_in           => Unsigned(1)                  <= stage1_a_sign
        stage2_a_is_zero  <= a_exponent_is_all_0 & a_fraction_is_all_0
        stage2_a_is_inf   <= a_exponent_is_all_1 & a_fraction_is_all_0
        stage2_a_is_nan   <= a_exponent_is_all_1 & a_fraction_is_not_0
        
        Wire      :b_exponent_is_all_1 => Unsigned(0)                  <= (stage1_b_exponent == i_exponent_all_1)
        Wire      :b_exponent_is_all_0 => Unsigned(0)                  <= (stage1_b_exponent == i_exponent_all_0)
        Wire      :b_fraction_is_all_0 => Unsigned(0)                  <= (stage1_b_fraction == i_fraction_all_0)
        Wire      :b_fraction_is_not_0 => Unsigned(0)                  <= !(b_fraction_is_all_0)
        Wire      :b_fraction_msb      => Unsigned(1)                  <= !(b_exponent_is_all_0)
        Wire      :b_fraction_in       => Unsigned(i_fraction_width+1) <= BitConcat(b_fraction_msb, stage1_b_fraction)
        Wire      :b_exponent_in       => Unsigned(i_exponent_width  ) <= stage1_b_exponent
        Wire      :b_sign_in           => Unsigned(1)                  <= stage1_b_sign
        stage2_b_is_zero  <= b_exponent_is_all_0 & b_fraction_is_all_0
        stage2_b_is_inf   <= b_exponent_is_all_1 & b_fraction_is_all_0
        stage2_b_is_nan   <= b_exponent_is_all_1 & b_fraction_is_not_0

        Wire      :a_abs_data          => Unsigned(i_width-1)          <= BitConcat(stage1_a_exponent, stage1_a_fraction)
        Wire      :b_abs_data          => Unsigned(i_width-1)          <= BitConcat(stage1_b_exponent, stage1_b_fraction)
        Wire      :b_gt_a              => Unsigned(0)                  <= (b_abs_data > a_abs_data)

        stage2_l_fraction <= Select(b_gt_a, a_fraction_in, b_fraction_in)
        stage2_l_exponent <= Select(b_gt_a, a_exponent_in, b_exponent_in)
        stage2_l_sign     <= Select(b_gt_a, a_sign_in    , b_sign_in    )

        stage2_s_fraction <= Select(b_gt_a, b_fraction_in, a_fraction_in)
        stage2_s_exponent <= Select(b_gt_a, b_exponent_in, a_exponent_in)
        stage2_s_sign     <= Select(b_gt_a, b_sign_in    , a_sign_in    )

        stage2_b_gt_a     <= b_gt_a
        stage2_sub        <= stage1_sub
      }

      stage3.on {
        Wire      :sub_xor_l_sign   => Unsigned(0) <= BitXor(stage2_sub, stage2_l_sign)
        stage3_t_sign <= Select(stage2_b_gt_a, stage2_l_sign, sub_xor_l_sign)
        stage3_op_sub <= BitXor(stage2_s_sign, sub_xor_l_sign)
        stage3_diff_exponent<= stage2_l_exponent - stage2_s_exponent
        if (t_exponent_width > i_exponent_width) then
          Constant :o_exponent_diff => Unsigned(t_exponent_width) <= (2**(t_exponent_width-1)-1) - (2**(i_exponent_width-1)-1)
          stage3_t_exponent <= stage2_l_exponent + o_exponent_diff
        else
          stage3_t_exponent <= stage2_l_exponent
        end
        stage3_l_fraction   <= stage2_l_fraction
        stage3_s_fraction   <= stage2_s_fraction
        stage3_b_gt_a       <= stage2_b_gt_a
        stage3_sub          <= stage2_sub
        stage3_a_is_zero    <= stage2_a_is_zero
        stage3_a_is_inf     <= stage2_a_is_inf
        stage3_a_is_nan     <= stage2_a_is_nan
        stage3_b_is_zero    <= stage2_b_is_zero
        stage3_b_is_inf     <= stage2_b_is_inf
        stage3_b_is_nan     <= stage2_b_is_nan
      }

      stage4.on {
        shift_width = 1
        while ((2**shift_width)-1 < t_fraction_width) do
          shift_width += 1
        end
        const_width = 1
        while ((2**const_width)-1 < s_fraction_width) do
          const_width += 1
        end
        Constant  :s_fraction_zero     => Unsigned(s_fraction_width) <= 0
        Constant  :s_fraction_msb      => Unsigned(1) <= 0
        Constant  :s_fraction_low      => Unsigned(s_fraction_width - o_fraction_width - 2) <= 0
        Wire      :shift_fractions     => Array.new(shift_width+1, Unsigned(s_fraction_width))
        0.upto(shift_width).each do |i|
          if i == 0 then
            shift_fractions[i] <= BitConcat(s_fraction_msb, stage3_s_fraction, s_fraction_low)
          else
            shift_fractions[i] <= Select(
                                    BitSel(stage3_diff_exponent, i-1),
                                    shift_fractions[i-1],
                                    BitConcat(To_Unsigned(0, 2**(i-1)), BitSel(shift_fractions[i-1], s_fraction_width-1, (2**(i-1)))))
          end
        end
        Constant  :t_fraction_zero     => Unsigned(t_fraction_width) <= 0
        Constant  :t_fraction_one      => Unsigned(t_fraction_width) <= 1
        Constant  :t_fraction_msb      => Unsigned(1) <= 0
        Constant  :t_fraction_low      => Unsigned(t_fraction_width - o_fraction_width - 2) <= 0
        Wire      :s_fraction_data     => Unsigned(t_fraction_width-1)
        Wire      :s_fraction          => Unsigned(t_fraction_width)
        Constant  :s_sticky_zero       => Unsigned(s_fraction_width - t_fraction_width + 1) <= 0
        Wire      :s_sticky_data       => Unsigned(s_fraction_width - t_fraction_width + 1)
        Wire      :s_sticky            => Unsigned(1)
        Wire      :s_under             => Unsigned(0)
        s_under             <= (stage3_diff_exponent >= To_Unsigned(t_fraction_width, const_width))
        s_fraction_data     <= BitSel(shift_fractions[shift_width], s_fraction_width - 1 ,
                                                                    s_fraction_width - t_fraction_width + 1)
        s_sticky_data       <= BitSel(shift_fractions[shift_width], s_fraction_width - t_fraction_width + 0, 0)
        s_sticky            <= (s_sticky_data != s_sticky_zero)
        s_fraction          <= BitConcat(s_fraction_data, s_sticky)
        stage4_sub          <= stage3_sub
        stage4_op_sub       <= stage3_op_sub
        stage4_b_gt_a       <= stage3_b_gt_a
        stage4_t_sign       <= stage3_t_sign
        stage4_t_exponent   <= stage3_t_exponent
        stage4_s_fraction   <= Select(s_under, s_fraction                 , t_fraction_one)
        stage4_l_fraction   <= BitConcat(t_fraction_msb, stage3_l_fraction, t_fraction_low)
        stage4_a_is_zero    <= stage3_a_is_zero
        stage4_a_is_inf     <= stage3_a_is_inf
        stage4_a_is_nan     <= stage3_a_is_nan
        stage4_b_is_zero    <= stage3_b_is_zero
        stage4_b_is_inf     <= stage3_b_is_inf
        stage4_b_is_nan     <= stage3_b_is_nan
      }

      stage5.on {
        Wire      :add_s_fraction      => Unsigned(t_fraction_width) <= stage4_s_fraction
        Wire      :sub_s_fraction      => Unsigned(t_fraction_width) <= BitInv(stage4_s_fraction) + To_Unsigned(1, t_fraction_width)
        Wire      :s_fraction          => Unsigned(t_fraction_width) <= Select(stage4_op_sub, add_s_fraction, sub_s_fraction)
        stage5_t_fraction   <= stage4_l_fraction + s_fraction
        stage5_sub          <= stage4_sub
        stage5_b_gt_a       <= stage4_b_gt_a
        stage5_t_exponent   <= stage4_t_exponent
        stage5_t_sign       <= stage4_t_sign
        stage5_a_is_zero    <= stage4_a_is_zero
        stage5_a_is_inf     <= stage4_a_is_inf
        stage5_a_is_nan     <= stage4_a_is_nan
        stage5_b_is_zero    <= stage4_b_is_zero
        stage5_b_is_inf     <= stage4_b_is_inf
        stage5_b_is_nan     <= stage4_b_is_nan
      }
      
      stage6.on {
        shift_width = 1
        while ((2**shift_width)-1 < t_fraction_width) do
          shift_width += 1
        end
        const_width = 1
        while ((2**const_width)-1 < t_fraction_width) do
          const_width += 1
        end
        Wire      :shift               => Unsigned(shift_width)
        Wire      :shift_flag          => Array.new(shift_width  , Unsigned(1))
        Constant  :fraction_zero       => Unsigned(t_fraction_width) <= 0
        Wire      :fraction_data       => Array.new(shift_width+1, Unsigned(t_fraction_width))
        Wire      :exponent_data       => Signed(1+t_exponent_width)
        shift_width.downto(0).each do |i|
          if (i == shift_width) then
            fraction_data[i] <= stage5_t_fraction
          else
            shift_flag[i]    <= Eq(BitSel(fraction_data[i+1], t_fraction_width-1, t_fraction_width-2**i), To_Unsigned(0, 2**i))
            fraction_data[i] <= Select(shift_flag[i],
                                       fraction_data[i+1],
                                       BitConcat(BitSel(fraction_data[i+1], t_fraction_width-2**i-1, 0),  To_Unsigned(0, 2**i)))
          end
        end
        shift <= BitConcat(*(shift_flag.reverse))
        stage6_t_exponent   <= stage5_t_exponent - shift + To_Unsigned(1, 1)
        stage6_t_fraction   <= fraction_data[0]
        stage6_t_sign       <= stage5_t_sign
        stage6_sub          <= stage5_sub
        stage6_b_gt_a       <= stage5_b_gt_a
        stage6_a_is_zero    <= stage5_a_is_zero
        stage6_a_is_inf     <= stage5_a_is_inf
        stage6_a_is_nan     <= stage5_a_is_nan
        stage6_b_is_zero    <= stage5_b_is_zero
        stage6_b_is_inf     <= stage5_b_is_inf
        stage6_b_is_nan     <= stage5_b_is_nan
      }
      
      stage7.on {
        const_width = 1
        while ((2**const_width)-1 < t_fraction_width) do
          const_width += 1
        end
        Constant  :fraction_all_1      => Unsigned(o_fraction_width+1) <= (0..o_fraction_width).to_a.inject(0){|d,n| d = d + 2**n}
        Wire      :fraction_data       => Unsigned(o_fraction_width+1) <= BitSel(stage6_t_fraction, t_fraction_width-1,
                                                                                                    t_fraction_width-o_fraction_width-1)
        Wire      :ulp                 => Unsigned(1)                  <= BitSel(stage6_t_fraction, t_fraction_width-o_fraction_width-1)
        Wire      :uulp1               => Unsigned(1)                  <= BitSel(stage6_t_fraction, t_fraction_width-o_fraction_width-2)
        Wire      :uulp2               => Unsigned(1)                  <= BitSel(stage6_t_fraction, t_fraction_width-o_fraction_width-3)
        Wire      :uulp3               => Unsigned(1)                  <= BitSel(stage6_t_fraction, t_fraction_width-o_fraction_width-4)
        Wire      :uulp4               => Unsigned(1)                  <= BitSel(stage6_t_fraction, t_fraction_width-o_fraction_width-5)
        Wire      :increment           => Unsigned(1)                  <= uulp1 & (ulp | uulp2 | uulp3 | uulp4)

        stage7_t_fraction <= fraction_data + increment
        stage7_t_exponent <= stage6_t_exponent + (increment & (fraction_data == fraction_all_1))
        stage7_t_sign     <= stage6_t_sign
        stage7_sub        <= stage6_sub
        stage7_b_gt_a     <= stage6_b_gt_a
        stage7_a_is_zero  <= stage6_a_is_zero
        stage7_a_is_inf   <= stage6_a_is_inf
        stage7_a_is_nan   <= stage6_a_is_nan
        stage7_b_is_zero  <= stage6_b_is_zero
        stage7_b_is_inf   <= stage6_b_is_inf
        stage7_b_is_nan   <= stage6_b_is_nan
      }

      stage8.on {
        Constant :zero_exponent   => Unsigned(o_exponent_width) <= 0
        Constant :zero_fraction   => Unsigned(o_fraction_width) <= 0
        Constant :inf_exponent    => Unsigned(o_exponent_width) <= 2**o_exponent_width-1
        Constant :inf_fraction    => Unsigned(o_fraction_width) <= 0
        Constant :nan_sign        => Unsigned(1)                <= 0
        Constant :nan_exponent    => Unsigned(o_exponent_width) <= 2**o_exponent_width-1
        Constant :nan_fraction    => Unsigned(o_fraction_width) <= 2**(o_fraction_width-2)

        Wire     :set_nan         => Unsigned(0) <= stage7_a_is_nan | stage7_b_is_nan | (stage7_a_is_inf & stage7_b_is_inf & stage7_sub)
        Wire     :set_inf         => Unsigned(0) <= !(set_nan) & (stage7_a_is_inf | stage7_b_is_inf)
        Wire     :set_zero        => Unsigned(0) <= stage7_a_is_zero & stage7_b_is_zero

        Wire     :fraction_msb    => Unsigned(1)                <= BitSel(stage7_t_fraction, o_fraction_width     )
        Wire     :fraction_in     => Unsigned(o_fraction_width) <= BitSel(stage7_t_fraction, o_fraction_width-1, 0)
        Wire     :exponent_in     => Unsigned(o_exponent_width) <= BitSel(stage7_t_exponent, o_exponent_width-1, 0)
        Wire     :sign_in         => Unsigned(1)                <= stage7_t_sign

        Constant :o_exponent_min  => Signed(o_exponent_width+1) <= 0
        Constant :o_exponent_max  => Signed(o_exponent_width+1) <= 2**(o_exponent_width)-1
        Wire     :exp_under       => Unsigned(0)                <= ~(stage7_t_exponent >  o_exponent_min) | ~(fraction_msb)
        Wire     :exp_over        => Unsigned(0)                <=  (stage7_t_exponent >= o_exponent_max) &   fraction_msb

        Wire     :fraction_i1     => Unsigned(o_fraction_width) <= Select(exp_over , fraction_in , inf_fraction )
        Wire     :exponent_i1     => Unsigned(o_exponent_width) <= Select(exp_over , exponent_in , inf_exponent )
        Wire     :sign_i1         => Unsigned(1)                <= sign_in

        Wire     :fraction_i2     => Unsigned(o_fraction_width) <= Select(exp_under, fraction_i1 , zero_fraction)
        Wire     :exponent_i2     => Unsigned(o_exponent_width) <= Select(exp_under, exponent_i1 , zero_exponent)
        Wire     :sign_i2         => Unsigned(1)                <= sign_i1

        Wire     :fraction_i3     => Unsigned(o_fraction_width) <= Select(set_nan  , fraction_i2 , nan_fraction )
        Wire     :exponent_i3     => Unsigned(o_exponent_width) <= Select(set_nan  , exponent_i2 , nan_exponent )
        Wire     :sign_i3         => Unsigned(1)                <= Select(set_nan  , sign_i2     , nan_sign     )

        Wire     :fraction_i4     => Unsigned(o_fraction_width) <= Select(set_inf  , fraction_i3 , inf_fraction )
        Wire     :exponent_i4     => Unsigned(o_exponent_width) <= Select(set_inf  , exponent_i3 , inf_exponent )
        Wire     :sign_i4         => Unsigned(1)                <= sign_i3

        Wire     :fraction_o      => Unsigned(o_fraction_width) <= Select(set_zero , fraction_i4 , zero_fraction)
        Wire     :exponent_o      => Unsigned(o_exponent_width) <= Select(set_zero , exponent_i4 , zero_exponent)
        Wire     :sign_o          => Unsigned(1)                <= sign_i4

        Wire     :result          => Unsigned(o_width)          <= BitConcat(sign_o, exponent_o, fraction_o)
        z_out    <= result
        z_valid  <= done
      }
    end
  end
end

puts design.to_exp("")
