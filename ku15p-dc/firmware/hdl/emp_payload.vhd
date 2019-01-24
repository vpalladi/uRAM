-- null_algo
--
-- Do-nothing top level algo for testing
--
-- Dave Newbold, July 2013

library IEEE;
use IEEE.STD_LOGIC_1164.all;

use work.ipbus.all;
use work.emp_data_types.all;
use work.top_decl.all;

use work.emp_device_decl.all;
use work.mp7_ttc_decl.all;

use work.ipbus_decode_emp_payload.all;

entity emp_payload is
  port(
    clk         : in  std_logic;        -- ipbus signals
    rst         : in  std_logic;

    ipb_in      : in  ipb_wbus;
    ipb_out     : out ipb_rbus;

    clk_payload : in  std_logic_vector(2 downto 0);
    rst_payload : in  std_logic_vector(2 downto 0);
    clk_p       : in  std_logic;        -- data clock

    rst_loc     : in  std_logic_vector(N_REGION - 1 downto 0);
    clken_loc   : in  std_logic_vector(N_REGION - 1 downto 0);

    ctrs        : in  ttc_stuff_array;

    bc0         : out std_logic;
    d           : in  ldata(4 * N_REGION - 1 downto 0);  -- data in
    q           : out ldata(4 * N_REGION - 1 downto 0);  -- data out

    gpio        : out std_logic_vector(29 downto 0);  -- IO to mezzanine connector
    gpio_en     : out std_logic_vector(29 downto 0)  -- IO to mezzanine connector (three-state enables)

    );

end emp_payload;

architecture rtl of emp_payload is

  type dr_t is array(PAYLOAD_LATENCY downto 0) of ldata(3 downto 0);

  signal uRAM_din  : lword;
  signal uRAM_dout : lword;

  attribute dont_touch              : string;
  attribute dont_touch of uRAM_din  : signal is "true";
  attribute dont_touch of uRAM_dout : signal is "true";

begin
  
--  ipb_out <= IPB_RBUS_NULL;


  -- to be automatically added to the payload
  fabric : entity work.ipbus_fabric_sel
    generic map(
      NSLV      => N_SLAVES,
      SEL_WIDTH => IPBUS_SEL_WIDTH)
    port map(
      ipb_in          => ipb_in,
      ipb_out         => ipb_out,
--      sel             => ipbus_sel_ipbus_example(ipb_in.ipb_addr),
      sel             => ipbus_sel_emp_payload(ipb_in.ipb_addr), -- from decode
                                                                 -- file
      ipb_to_slaves   => ipbw,
      ipb_from_slaves => ipbr
      );


--  gen : for i in N_REGION - 1 downto 0 generate
--  --gen : for i in 10 downto 0 generate
--
--    constant ich : integer := i * 4;
--    
--  begin

    --dr(0) <= d(ich downto icl);

    uRAM_1 : entity work.uRAM
      port map (
        clk   => clk_p,
        rst   => rst,
        wen   => '1',
        d_in  => d(0),
        d_out => q(0),
        ipb_clk => clk,
        ipb_in  => ipbw(N_SLV_URAM_0),
        ipb_out => ipbr(N_SLV_URAM_0)
        );     

    uRAM_2 : entity work.uRAM
      port map (
        clk   => clk_p,
        rst   => rst,
        wen   => '1',
        d_in  => d(1),
        d_out => q(1)
        ipb_clk => clk,
        ipb_in  => ipbw(N_SLV_URAM_1),
        ipb_out => ipbr(N_SLV_URAM_1)
        );

--    uRAM_3 : entity work.uRAM
--      port map (
--        clk   => clk_p,
--        rst   => rst,
--        wen   => '1',
--        d_in  => d(ich+2),
--        d_out => q(ich+2)
--        ipb_clk => clk,
--        ipb_in  => ipb_in,
--        ipb_out => ipb_out
--        );
--
--    uRAM_4 : entity work.uRAM
--      port map (
--        clk   => clk_p,
--        rst   => rst,
--        wen   => '1',
--        d_in  => d(ich+3),
--        d_out => q(ich+3)
--        ipb_clk => clk,
--        ipb_in  => ipb_in,
--        ipb_out => ipb_out
--        );

  end generate;

  bc0 <= '0';

  gpio    <= (others => '0');
  gpio_en <= (others => '0');

end rtl;
