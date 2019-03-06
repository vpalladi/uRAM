

library xpm;
use xpm.vcomponents.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.emp_data_types.all;
use work.ipbus.all;


entity ipbus_uRAM is
  generic (
    uRAM_depth : integer := 12          -- bit
    );
  port (
    clk : in std_logic;
    rst : in std_logic;
    wen   : in  std_logic;
    d_in  : in  lword;
    d_out : out lword;

    ipb_clk : in std_logic;
    ipb_in  : in  ipb_wbus;
    ipb_out : out ipb_rbus

    );

end ipbus_uRAM;


architecture rtl of ipbus_uRAM is

  signal uRAM_clk     : std_logic;
  signal uRAM_rst     : std_logic;
  signal uRAM_we      : std_logic_vector(0 downto 0);
  signal uRAM_dataIn  : std_logic_vector(71 downto 0);
  signal uRAM_addrIn  : std_logic_vector(uRAM_depth-1 downto 0);
  signal uRAM_dataOut : std_logic_vector(71 downto 0);
  signal uRAM_addrOut : std_logic_vector(uRAM_depth-1 downto 0);

  signal ack         : std_logic_vector(3 downto 0);
  
  signal ipb_we        : std_logic_vector(0 downto 0);
  
begin  -- architecture rtl


  --===== ipbus clock domain ==========--
  ipb_out.ipb_ack <= ack(0);

  rd_wr_uRAM: process (ipb_clk) is
  begin  -- process read_write_uRAM
    if rising_edge(ipb_clk) then

      ack <= '0' & ack(3 downto 1);      
      
      ipb_we(0) <= '0';
      
      if ipb_in.ipb_strobe = '1' and ack = "0000" then

        -- writing
        if ipb_in.ipb_write = '1' then
          ipb_we(0) <= '1';
          ack <= "0010";
        end if;
        
        -- reading 
        if ipb_in.ipb_write = '0' then
          ack <= "1000";
        end if;

      end if;
        
    end if;  
  end process rd_wr_uRAM;
  
  ipbus_ila_inst : entity work.ipbus_ila
  port map 
  (
    clk                    => ipb_clk,
    probe0( 11 downto   0) => ipb_in.ipb_addr(uRAM_depth-1 downto 0),      
    probe0( 31 downto  12) => (others =>'0'),
    probe0( 63 downto  32) => ipb_in.ipb_wdata, 
    probe0( 64)            => ipb_in.ipb_strobe,     
    probe0( 65)            => ipb_in.ipb_strobe,     
    probe0( 66 downto  66) => ipb_we,     
    probe0( 70 downto  67) => ack     
  );
  --===================================--



  --===== clock domain crossing =======--
  cdc_addr : entity work.sync_ffs generic map (nbr_bits => 12) port map (clk_i => uRAM_clk, data_i => ipb_in.ipb_addr(uRAM_depth-1 downto 0), synced_o => uRAM_addrIn);
  cdc_wdata: entity work.sync_ffs generic map (nbr_bits => 32) port map (clk_i => uRAM_clk, data_i => ipb_in.ipb_wdata,                       synced_o => uRAM_dataIn(31 downto 0));
  cdc_wen:   entity work.sync_ffs generic map (nbr_bits =>  1) port map (clk_i => uRAM_clk, data_i => ipb_we,                                 synced_o => uRAM_we);
  cdc_rdata: entity work.sync_ffs generic map (nbr_bits => 32) port map (clk_i => ipb_clk,  data_i => uRAM_dataOut(31 downto 0),              synced_o => ipb_out.ipb_rdata);
  --===================================--



  --===== uRAM clock domain ===========--
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
  
  
  uRAM_dataIn(71 downto 32) <= (others => '0');
  uRAM_addrOut <= uRAM_addrIn;
  uRAM_clk   <= clk;
  uRAM_rst   <= rst;
  
  

  uRAM_ila_inst : entity work.uRAM_ila
  port map 
  (
    clk                    => uRAM_clk,
    probe0( 71 downto   0) => uRAM_dataIn,      
    probe0( 83 downto  72) => uRAM_addrIn, 
    probe0(103 downto  84) => (others => '0'), 
    probe0(104 downto 104) => uRAM_we,     
    probe0(176 downto 105) => uRAM_dataOut     
  );
  

  --=====================================--





end architecture rtl;




