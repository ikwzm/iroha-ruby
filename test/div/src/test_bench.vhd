library ieee;
use     ieee.std_logic_1164.all;
entity  TEST_BENCH is
    generic (
        NAME            : STRING := "TEST";
        SCENARIO_FILE   : STRING := "test.snr"
    );
end     TEST_BENCH;
use     std.textio.all;
library DUMMY_PLUG;
use     DUMMY_PLUG.AXI4_TYPES.all;
use     DUMMY_PLUG.AXI4_MODELS.AXI4_STREAM_MASTER_PLAYER;
use     DUMMY_PLUG.AXI4_MODELS.AXI4_STREAM_SLAVE_PLAYER;
use     DUMMY_PLUG.SYNC.all;
use     DUMMY_PLUG.CORE.MARCHAL;
use     DUMMY_PLUG.CORE.REPORT_STATUS_TYPE;
use     DUMMY_PLUG.CORE.REPORT_STATUS_VECTOR;
use     DUMMY_PLUG.CORE.MARGE_REPORT_STATUS;
architecture stimulus of TEST_BENCH is
    ----------------------------------------------------------------------------
    -- 
    ----------------------------------------------------------------------------
    constant CLOCK_PERIOD    : time    := 10 ns;
    constant DELAY           : time    :=  1 ns;
    constant MATCH_PHASE     : integer :=  8;
    constant I_BYTES         : integer :=  8;  -- 32bit x 2 = 64bit = 8byte
    constant I_WIDTH         : AXI4_STREAM_SIGNAL_WIDTH_TYPE := (
                                 ID    => 4,
                                 USER  => 4,
                                 DEST  => 4,
                                 DATA  => 8*I_BYTES);
    constant O_BYTES         : integer :=  8;  -- 32bit x 2 = 64bit = 8byte
    constant O_WIDTH         : AXI4_STREAM_SIGNAL_WIDTH_TYPE := (
                                 ID    => 4,
                                 USER  => 4,
                                 DEST  => 4,
                                 DATA  => 8*O_BYTES);
    constant SYNC_WIDTH      : integer :=  2;
    constant GPO_WIDTH       : integer :=  8;
    constant GPI_WIDTH       : integer :=  GPO_WIDTH;
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    signal   ARESETn         : std_logic;
    signal   RESET           : std_logic;
    signal   CLOCK           : std_logic;
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    signal   SYNC            : SYNC_SIG_VECTOR (SYNC_WIDTH     -1 downto 0);
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    signal   I_TDATA         : std_logic_vector(I_WIDTH.DATA   -1 downto 0);
    signal   I_TKEEP         : std_logic_vector(I_WIDTH.DATA/8 -1 downto 0);
    signal   I_TLAST         : std_logic;
    signal   I_TVALID        : std_logic;
    signal   I_TREADY        : std_logic;
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    signal   O_TDATA         : std_logic_vector(O_WIDTH.DATA   -1 downto 0);
    signal   O_TKEEP         : std_logic_vector(O_WIDTH.DATA/8 -1 downto 0) := (others => '1');
    signal   O_TUSER         : std_logic_vector(O_WIDTH.USER   -1 downto 0) := (others => '0');
    constant O_TDEST         : std_logic_vector(O_WIDTH.DEST   -1 downto 0) := (others => '0');
    constant O_TID           : std_logic_vector(O_WIDTH.ID     -1 downto 0) := (others => '0');
    signal   O_TLAST         : std_logic;
    signal   O_TVALID        : std_logic;
    signal   O_TREADY        : std_logic;
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    signal   I_GPI           : std_logic_vector(GPI_WIDTH      -1 downto 0);
    signal   I_GPO           : std_logic_vector(GPO_WIDTH      -1 downto 0);
    signal   O_GPI           : std_logic_vector(GPI_WIDTH      -1 downto 0);
    signal   O_GPO           : std_logic_vector(GPO_WIDTH      -1 downto 0);
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    signal   N_REPORT        : REPORT_STATUS_TYPE;
    signal   I_REPORT        : REPORT_STATUS_TYPE;
    signal   O_REPORT        : REPORT_STATUS_TYPE;
    signal   N_FINISH        : std_logic;
    signal   I_FINISH        : std_logic;
    signal   O_FINISH        : std_logic;
    ----------------------------------------------------------------------------
    -- 
    ----------------------------------------------------------------------------
    component div
        port(
          clk       : in  std_logic;
          rst_n     : in  std_logic;
          i_valid   : in  std_logic;
          dividend  : in  std_logic_vector(31 downto 0);
          divisor   : in  std_logic_vector(15 downto 0);
          quotient  : out std_logic_vector(31 downto 0);
          remainder : out std_logic_vector(15 downto 0);
          o_valid   : out std_logic
        );
    end component;
    ----------------------------------------------------------------------------
    -- 
    ----------------------------------------------------------------------------
    signal    i_valid        : std_logic;
    signal    dividend       : std_logic_vector(31 downto 0);
    signal    divisor        : std_logic_vector(15 downto 0);
    signal    quotient       : std_logic_vector(31 downto 0);
    signal    remainder      : std_logic_vector(15 downto 0);
    constant  zero_16        : std_logic_vector(15 downto 0) := (others => '0');
    signal    o_valid        : std_logic;
    signal    o_last         : std_logic_vector(32 downto 0);
begin
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    N: MARCHAL
        generic map(
            SCENARIO_FILE   => SCENARIO_FILE,
            NAME            => "MARCHAL",
            SYNC_PLUG_NUM   => 1,
            SYNC_WIDTH      => SYNC_WIDTH,
            FINISH_ABORT    => FALSE
        )
        port map(
            CLK             => CLOCK           , -- In  :
            RESET           => RESET           , -- In  :
            SYNC(0)         => SYNC(0)         , -- I/O :
            SYNC(1)         => SYNC(1)         , -- I/O :
            REPORT_STATUS   => N_REPORT        , -- Out :
            FINISH          => N_FINISH          -- Out :
        );
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    I: AXI4_STREAM_MASTER_PLAYER                 -- 
        generic map (                            -- 
            SCENARIO_FILE   => SCENARIO_FILE   , --
            NAME            => "I"             , --
            OUTPUT_DELAY    => DELAY           , --
            SYNC_PLUG_NUM   => 2               , --
            WIDTH           => I_WIDTH         , --
            SYNC_WIDTH      => SYNC_WIDTH      , --
            GPI_WIDTH       => GPI_WIDTH       , --
            GPO_WIDTH       => GPO_WIDTH       , --
            FINISH_ABORT    => FALSE             --
        )                                        -- 
        port map (                               -- 
            ACLK            => CLOCK           , -- In  :
            ARESETn         => ARESETn         , -- In  :
            TDATA           => I_TDATA         , -- Out :
            TSTRB           => open            , -- Out :
            TKEEP           => I_TKEEP         , -- Out :
            TUSER           => open            , -- Out :
            TDEST           => open            , -- Out :
            TID             => open            , -- Out :
            TLAST           => I_TLAST         , -- Out :
            TVALID          => I_TVALID        , -- Out :
            TREADY          => I_TREADY        , -- In  :
            SYNC            => SYNC            , -- I/O :
            GPI             => I_GPI           , -- In  :
            GPO             => I_GPO           , -- Out :
            REPORT_STATUS   => I_REPORT        , -- Out :
            FINISH          => I_FINISH          -- Out :
        );                                       -- 
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    O: AXI4_STREAM_SLAVE_PLAYER                  -- 
        generic map (                            -- 
            SCENARIO_FILE   => SCENARIO_FILE   , --
            NAME            => "O"             , --
            OUTPUT_DELAY    => DELAY           , --
            SYNC_PLUG_NUM   => 3               , --
            WIDTH           => O_WIDTH         , --
            SYNC_WIDTH      => SYNC_WIDTH      , --
            GPI_WIDTH       => GPI_WIDTH       , --
            GPO_WIDTH       => GPO_WIDTH       , --
            FINISH_ABORT    => FALSE             --
        )                                        -- 
        port map(                                -- 
            ACLK            => CLOCK           , -- In  :
            ARESETn         => ARESETn         , -- In  :
            TDATA           => O_TDATA         , -- In  :
            TSTRB           => O_TKEEP         , -- In  :
            TKEEP           => O_TKEEP         , -- In  :
            TUSER           => O_TUSER         , -- In  :
            TDEST           => O_TDEST         , -- In  :
            TID             => O_TID           , -- In  :
            TLAST           => O_TLAST         , -- In  :
            TVALID          => O_TVALID        , -- In  :
            TREADY          => O_TREADY        , -- Out :
            SYNC            => SYNC            , -- Inou:
            GPI             => O_GPI           , -- In  :
            GPO             => O_GPO           , -- Out :
            REPORT_STATUS   => O_REPORT        , -- Out :
            FINISH          => O_FINISH          -- Out :
        );                                       -- 
    ----------------------------------------------------------------------------
    -- 
    ----------------------------------------------------------------------------
    DUT: div port map(
      clk       => CLOCK    ,
      rst_n     => ARESETn  ,
      i_valid   => i_valid  ,
      dividend  => dividend ,
      divisor   => divisor  ,
      quotient  => quotient , 
      remainder => remainder,
      o_valid   => o_valid
    );
    i_valid  <= I_TVALID;
    dividend <= I_TDATA(31 downto  0);
    divisor  <= I_TDATA(47 downto 32);
    I_TREADY <= '1';
    process(CLOCK, RESET) begin
        if (RESET = '1') then
            o_last  <= (others => '0');
        elsif (CLOCK'event and CLOCK = '1') then
            for i in o_last'range loop
                if (i = 0) then
                    o_last(i)  <= I_TLAST;
                else
                    o_last(i)  <= o_last(i-1);
                end if;
            end loop;
        end if;
    end process;
    O_TDATA  <= zero_16 & remainder & quotient;
    O_TVALID <= o_valid;
    O_TLAST  <= o_last(o_last'high);
    O_TKEEP  <= (others => '1');
    O_TUSER  <= (others => '0');
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    process begin
        CLOCK <= '0';
        wait for CLOCK_PERIOD / 2;
        CLOCK <= '1';
        wait for CLOCK_PERIOD / 2;
    end process;

    ARESETn <= '1' when (RESET = '0') else '0';
    process
        variable L   : LINE;
        constant T   : STRING(1 to 7) := "  ***  ";
    begin
        wait until (O_FINISH'event and O_FINISH = '1');
        wait for DELAY;
        WRITE(L,T);                                                   WRITELINE(OUTPUT,L);
        WRITE(L,T & "ERROR REPORT " & NAME);                          WRITELINE(OUTPUT,L);
        WRITE(L,T & "[ I ]");                                         WRITELINE(OUTPUT,L);
        WRITE(L,T & "  Error    : ");WRITE(L,I_REPORT.error_count   );WRITELINE(OUTPUT,L);
        WRITE(L,T & "  Mismatch : ");WRITE(L,I_REPORT.mismatch_count);WRITELINE(OUTPUT,L);
        WRITE(L,T & "  Warning  : ");WRITE(L,I_REPORT.warning_count );WRITELINE(OUTPUT,L);
        WRITE(L,T & "[ O ]");                                         WRITELINE(OUTPUT,L);
        WRITE(L,T & "  Error    : ");WRITE(L,O_REPORT.error_count   );WRITELINE(OUTPUT,L);
        WRITE(L,T & "  Mismatch : ");WRITE(L,O_REPORT.mismatch_count);WRITELINE(OUTPUT,L);
        WRITE(L,T & "  Warning  : ");WRITE(L,O_REPORT.warning_count );WRITELINE(OUTPUT,L);
        WRITE(L,T);                                                   WRITELINE(OUTPUT,L);
        assert FALSE report "Simulation complete." severity FAILURE;
        wait;
    end process;
end stimulus;

