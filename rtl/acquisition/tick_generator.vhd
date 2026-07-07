--=============================================================================
-- Entity: tick_generator
-- Description:
-- Produces a one-clock sampling tick every FREQUENCY_DIVIDER_RATIO cycles
-- of the 1 MHz system clock. The ratio is driven at runtime by
-- freq_ratio_controller, making the oscilloscope sampling rate
-- push-button adjustable.
-- Based on the ENGS 31 Lab 6 template; modified to accept the divider
-- ratio as an input port instead of a generic.
--=============================================================================

--=============================================================================
--Library Declarations:
--=============================================================================
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

--=============================================================================
--Entity Declaration:
--=============================================================================
entity tick_generator is
	port (
	    FREQUENCY_DIVIDER_RATIO : in integer;
		system_clk_port  : in  std_logic;
		tick_port		 : out std_logic);
end tick_generator;

--=============================================================================
--Architecture Type:
--=============================================================================
architecture behavioral_architecture of tick_generator is
--=============================================================================
--Signal Declarations: 
--=============================================================================
-- The divider ratio is a runtime input (from freq_ratio_controller)
-- rather than a generic, so the counter is fixed at 16 bits to cover
-- the full MIN_FREQ..MAX_FREQ range.
signal frequency_divider_counter : unsigned(15 downto 0) := (others => '0');
--=============================================================================
--Processes: 
--=============================================================================
begin
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--Frequency Divider:
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
frequency_divider: process(system_clk_port, frequency_divider_counter)
begin
	if rising_edge(system_clk_port) then
	   	if frequency_divider_counter = to_unsigned(FREQUENCY_DIVIDER_RATIO - 1, 16) then 	  
			frequency_divider_counter <= (others => '0');			  -- Reset
		else
			frequency_divider_counter <= frequency_divider_counter + 1; -- Count up
		end if;
	end if;
	
	if frequency_divider_counter = 0 then tick_port <= '1';
	else tick_port <= '0';
	end if;
end process frequency_divider;

end behavioral_architecture;