

library xpm;
use xpm.vcomponents.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uRAM is
  generic (

    uRAM_depth : integer := 12          -- bit

    );
  port (
    
    clk     : in  std_logic;
    rst     : in  std_logic;
    we      : in  std_logic_vector(0 downto 0);
    dataIn  : in  std_logic_vector(71 downto 0);
    addrIn  : in  std_logic_vector(uRAM_depth-1 downto 0);
    dataOut : out std_logic_vector(71 downto 0);
    addrOut : in  std_logic_vector(uRAM_depth-1 downto 0)

    );

end uRAM;

architecture rtl of uRAM is

begin  -- architecture rtl

  -- xpm_memory_sdpram: Simple Dual Port RAM
  -- Xilinx Parameterized Macro, version 2018.2
  
  xpm_memory_sdpram_inst : xpm_memory_sdpram
    generic map (
      ADDR_WIDTH_A            => uRAM_depth,          -- DECIMAL
      ADDR_WIDTH_B            => uRAM_depth,          -- DECIMAL
      AUTO_SLEEP_TIME         => 0,     -- DECIMAL
      BYTE_WRITE_WIDTH_A      => 72,    -- DECIMAL
      CLOCKING_MODE           => "common_clock",      -- String
      ECC_MODE                => "no_ecc",            -- String
      MEMORY_INIT_FILE        => "none",              -- String
      MEMORY_INIT_PARAM       => "0",   -- String
      MEMORY_OPTIMIZATION     => "false",             -- String
      MEMORY_PRIMITIVE        => "ultra",             -- String
      MEMORY_SIZE             => (2**uRAM_depth)*72,  -- DECIMAL----------------
      MESSAGE_CONTROL         => 0,     -- DECIMAL
      READ_DATA_WIDTH_B       => 72,    -- DECIMAL
      READ_LATENCY_B          => 2,     -- DECIMAL
      READ_RESET_VALUE_B      => "0",   -- String
      USE_EMBEDDED_CONSTRAINT => 0,     -- DECIMAL
      USE_MEM_INIT            => 0,     -- DECIMAL
      WAKEUP_TIME             => "disable_sleep",     -- String
      WRITE_DATA_WIDTH_A      => 72,    -- DECIMAL
      WRITE_MODE_B            => "read_first"         -- String
      )
    port map (

      doutb          => dataOut,
      addra          => addrIn,
      addrb          => addrOut,
      clka           => clk,
      clkb           => clk,
      dina           => dataIn,
      ena            => '1',
      enb            => '1',
      injectdbiterra => '0',
      injectsbiterra => '0',
      regceb         => '1',
      rstb           => '0',
      sleep          => '0',
      wea            => we

      );


end architecture rtl;




