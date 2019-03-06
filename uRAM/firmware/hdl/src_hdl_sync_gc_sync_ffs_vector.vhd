library ieee;
use ieee.std_logic_1164.all;

entity sync_ffs is
  generic( 
    nbr_bits    : positive := 1 ;
    g_sync_edge : string   := "positive"
    );
  port(
    clk_i    : in  std_logic;                              -- clock from the destination clock domain
    rst_n_i  : in  std_logic:='1';                         -- reset
    data_i   : in  std_logic_vector(nbr_bits-1 downto 0);  -- async input
    synced_o : out std_logic_vector(nbr_bits-1 downto 0);  -- synchronized output
    npulse_o : out std_logic_vector(nbr_bits-1 downto 0);  -- negative edge detect output (single-clock pulse)
    ppulse_o : out std_logic_vector(nbr_bits-1 downto 0)   -- positive edge detect output (single-clock pulse)
    );
end sync_ffs;

architecture behavioral of sync_ffs is

begin

vec: for i in 0 to nbr_bits-1 generate
  ff: entity work.gc_sync_ffs
  generic map( g_sync_edge => g_sync_edge)
  port map
  (
    clk_i    => clk_i,       -- clock from the destination clock domain
    rst_n_i  => rst_n_i,     -- reset
    data_i   => data_i  (i), -- async input
    synced_o => synced_o(i), -- synchronized output
    npulse_o => npulse_o(i), -- negative edge detect output (single-clock pulse)
    ppulse_o => ppulse_o(i)  -- positive edge detect output (single-clock pulse)
  );
end generate;  

end behavioral;

