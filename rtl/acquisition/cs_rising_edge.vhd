-- ========================================================
-- Entity: cs_rising_edge
-- Description:
-- Detects the low-to-high transition of the ADC chip-select
-- signal, which marks the completion of an SPI transaction,
-- and asserts new_data to trigger insertion of the finished
-- sample into the oscilloscope display buffer. spi_cs crosses
-- from the 1 MHz acquisition domain into the 100 MHz display
-- domain through a 2-stage synchronizer.
-- ========================================================

-- **Library Declarations**
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

-- **Entity Declaration**
entity cs_rising_edge is
    Port (
        clk                 : in  STD_LOGIC;
        spi_cs              : in  STD_LOGIC;
        new_data            : out STD_LOGIC
    );
end cs_rising_edge;

architecture Behavioral of cs_rising_edge is

-- internal signals

signal cs_prev : STD_LOGIC := '0';
signal cs_sync1 :  STD_LOGIC := '0';
signal cs_sync2 :  STD_LOGIC := '0';

begin

cs_rising_edge_inst : process(clk, spi_cs)
begin
    if rising_edge(clk) then
        cs_sync1 <= spi_cs;
        cs_sync2 <= cs_sync1;
        
        if cs_sync2 = '1' and cs_prev = '0' then 
            new_data <= '1';
        else 
            new_data <= '0';
        end if;
        
        cs_prev <= cs_sync2;
        
    end if;
end process;

end Behavioral;
