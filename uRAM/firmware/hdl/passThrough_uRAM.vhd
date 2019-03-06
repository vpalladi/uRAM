

library xpm;
use xpm.vcomponents.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.emp_data_types.all;
use work.ipbus.all;


entity passThrough_uRAM is
  generic (
    uRAM_depth : integer := 12          -- bit
    );
  port (
    clk : in std_logic;
    rst : in std_logic;
    
    d_in  : in  lword;
    d_out : out lword

    );

end passThrough_uRAM;


architecture rtl of passThrough_uRAM is

  signal uRAM_clk     : std_logic;
  signal uRAM_rst     : std_logic;
  signal uRAM_we      : std_logic_vector(0 downto 0);
  signal uRAM_dataIn  : std_logic_vector(71 downto 0);
  signal uRAM_addrIn  : std_logic_vector(uRAM_depth-1 downto 0);
  signal uRAM_dataOut : std_logic_vector(71 downto 0);
  signal uRAM_addrOut : std_logic_vector(uRAM_depth-1 downto 0);

  constant last_address : std_logic_vector(uRAM_depth-1 downto 0)  := (others => '1');
  
begin  -- architecture rtl
  
  d_out.strobe <= '1';
  
  -- uRAM 
  uRAM_clk   <= clk;
  
  rd_wr_uRAM: process (clk) is
  begin  -- process read_write_uRAM
    if rising_edge(clk) then

      if rst = '1' then
        
        uRAM_addrIn  <= (others => '0');
        uRAM_addrOut <= (others => '0');
    
      else
        if d_in.valid = '1' then
          
          if uRAM_addrIn = last_address then
            uRAM_addrIn  <= (others => '0');        
          else
            uRAM_addrIn  <= std_logic_vector( unsigned(uRAM_addrIn) + 1 );
          end if;
          
          uRAM_addrOut <= uRAM_addrIn;
       
        end if;

        uRAM_we(0) <= d_in.valid;
        d_out.valid <= uRAM_we(0);
        
      end if;
      
    end if;
    
  end process rd_wr_uRAM;


  uRAM: entity work.uRAM
    generic map (
      uRAM_depth => uRAM_depth
      )
    port map (
      clk     => uRAM_clk,
      rst     => uRAM_rst,
      we      => uRAM_we,
      dataIn  => uRAM_dataIn,
      addrIn  => uRAM_addrIn,
      dataOut => uRAM_dataOut,
      addrOut => uRAM_addrOut
      );

   d_out.data <= uRAM_dataOut(63 downto 0);
  

end architecture rtl;




