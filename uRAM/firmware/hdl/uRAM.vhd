

library xpm;
use xpm.vcomponents.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.emp_data_types.all;
use work.ipbus.all;


entity uRAM is
  generic (
    uRAM_depth : integer := 12 -- bit
    );
  port (
    clk   : in std_logic;
    rst   : in std_logic;

    wen   : in std_logic;
    d_in  : in  lword;
    d_out : out lword;

    ipb_clk : in  std_logic;

    ipb_in      : in  ipb_wbus;
    ipb_out     : out ipb_rbus

    );

end uRAM;

architecture rtl of uRAM is

  signal uRAM_clk    : std_logic;
  signal uRAM_rst    : std_logic;
  signal uRAM_we     : std_logic_vector(0 downto 0);
  signal uRAM_regce  : std_logic;
  signal uRAM_mem_en : std_logic;
  signal uRAM_din    : std_logic_vector(71 downto 0);
  signal uRAM_din_1  : std_logic_vector(71 downto 0);
  signal uRAM_addrA  : std_logic_vector(uRAM_depth-1 downto 0);
  signal uRAM_addrB  : std_logic_vector(uRAM_depth-1 downto 0);
  signal uRAM_dout   : std_logic_vector(71 downto 0);
  signal uRAM_dout_1 : std_logic_vector(71 downto 0);

--  type my_state is (S0, S1, S2);

--  signal state : my_state := S0;
  
begin  -- architecture rtl


  registers: process (clk) is
  begin  -- process registers
    if rising_edge(clk) then  -- rising clock edge

      uRAM_din <= d_in.data & x"00";
      uRAM_din_1 <= uRAM_din;

      uRAM_dout_1 <= uRAM_dout;
      d_out.data <= uRAM_dout_1(63 downto 0);
      
    end if;
  end process registers;

  
  -- xpm_memory_sdpram: Simple Dual Port RAM
  -- Xilinx Parameterized Macro, version 2018.2

  -- address 
  addr: process (clk, rst) is
    
  begin  -- process addr
    if rst = '0' then                   -- asynchronous reset (active low)
      uRAM_addrA <= (others => '0');
      uRAM_addrB <= (others => '0');
    elsif rising_edge(clk) then  -- rising clock edge

      if uRAM_addrA = x"FFF" then
        uRAM_addrA <= x"000";
      else
        uRAM_addrA <= std_logic_vector( unsigned(uRAM_addrA) + 1 ) ;
      end if;

      if uRAM_addrB = x"FFF" then
        uRAM_addrB <= x"000";
      else
        uRAM_addrB <= std_logic_vector( unsigned(uRAM_addrB) + 1 ) ;
      end if;

      
    end if;
  end process addr;
  
  uRAM_clk     <= clk;  
  uRAM_rst     <= rst;  
  uRAM_we      <= (others => wen);
  
--   xpm_memory_sdpram_inst : entity xpm.xpm_memory_sdpram
  xpm_memory_sdpram_inst : xpm_memory_sdpram
    generic map (
      ADDR_WIDTH_A => uRAM_depth,              -- DECIMAL
      ADDR_WIDTH_B => uRAM_depth,              -- DECIMAL
      AUTO_SLEEP_TIME => 0,            -- DECIMAL
      BYTE_WRITE_WIDTH_A => 72,        -- DECIMAL
      CLOCKING_MODE => "common_clock", -- String
      ECC_MODE => "no_ecc",            -- String
      MEMORY_INIT_FILE => "none",      -- String
      MEMORY_INIT_PARAM => "0",        -- String
      MEMORY_OPTIMIZATION => "false",  -- String
      MEMORY_PRIMITIVE => "ultra",     -- String
      MEMORY_SIZE => (2**uRAM_depth)*72,           -- DECIMAL----------------
      MESSAGE_CONTROL => 0,            -- DECIMAL
      READ_DATA_WIDTH_B => 72,         -- DECIMAL
      READ_LATENCY_B => 2,             -- DECIMAL
      READ_RESET_VALUE_B => "0",       -- String
      USE_EMBEDDED_CONSTRAINT => 0,    -- DECIMAL
      USE_MEM_INIT => 0,               -- DECIMAL
      WAKEUP_TIME => "disable_sleep",  -- String
      WRITE_DATA_WIDTH_A => 72,        -- DECIMAL
      WRITE_MODE_B => "read_first"      -- String
   )
   port map (

      doutb => uRAM_dout,
      addra => uRAM_addrA,
      addrb => uRAM_addrB,
      clka  => uRAM_clk,
      clkb  => uRAM_clk,
      dina  => uRAM_din_1,
      ena   => '1',
      enb   => '1',
      injectdbiterra => '0',
      injectsbiterra => '0',
      regceb         => '1',
      rstb           => '0',
      sleep          => '0',
      wea            => uRAM_we
      
   );

 


  
--  FSM: process (clk, rst) is
--
--    variable counter : integer := 0;
--
--  begin  -- process FSM
--    if rst = '0' then                   -- asynchronous reset (active low)
--      state <= S0;
--    elsif rising_edge(clk) then  -- rising clock edge
--
--      case state is
--        when S0 => ;
--        when S1 => ;
--        when S2 => ;
--        when others => null;
--      end case;
--
--      counter := counter + 1;
--      
--    end if;
--  end process FSM;


  
end architecture rtl;




