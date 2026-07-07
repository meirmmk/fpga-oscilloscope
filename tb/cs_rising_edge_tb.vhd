library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity cs_rising_edge_tb is
end cs_rising_edge_tb;

architecture tb of cs_rising_edge_tb is

    signal clk      : std_logic := '0';
    signal spi_cs   : std_logic := '0';
    signal new_data : std_logic;

begin

    ------------------------------------------------------------------
    -- DUT
    ------------------------------------------------------------------
    uut : entity work.cs_rising_edge
        port map (
            clk      => clk,
            spi_cs   => spi_cs,
            new_data => new_data
        );

    ------------------------------------------------------------------
    -- 100 MHz clock
    ------------------------------------------------------------------
    clk <= not clk after 5 ns;

    ------------------------------------------------------------------
    -- Stimulus
    ------------------------------------------------------------------
    process
    begin

        --------------------------------------------------------------
        -- Rising edge #1
        --------------------------------------------------------------
        spi_cs <= '1';
        wait for 1000 ns;
        
        wait;
    end process;

end tb;