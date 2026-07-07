-- ========================================================
-- Entity: adc_data_shiftreg
-- Description: 
-- Receives the 12-bit voltage values from the adc+spi receiver 
-- and stores them to a shift register which shifts voltage values 
-- in from the right side of the screen. Outputs a 640-deep array bus 
-- containing 12-bit voltage values.
-- ========================================================

-- **Library Declarations**
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

-- custom array bus types and sizes
use work.bus_types_sizes.voltage_reg_t;
use work.bus_types_sizes.ADC_DATA_WIDTH_C;
use work.bus_types_sizes.SCREEN_WIDTH;

-- **Entity Declaration**
entity adc_data_shiftreg is
    Port (
        clk                 : in  STD_LOGIC;
        adc_data            : in  STD_LOGIC_VECTOR(ADC_DATA_WIDTH_C-1 downto 0);
        shift_en            : in  STD_LOGIC;
        voltage_sr          : out voltage_reg_t := (others=>(others=>'0'))
    );
end adc_data_shiftreg;

architecture Behavioral of adc_data_shiftreg is

-- internal signals
signal voltage_sr_i : voltage_reg_t := (others => (others=>'0'));

begin
    -- shiftreg with 12 bit data, shifts in data from the right side of the screen
    adc_data_shift_reg : process(clk)
    begin
        if rising_edge(clk) then
            if shift_en = '1' then
                voltage_sr_i(0 to SCREEN_WIDTH - 2) <= voltage_sr_i(1 to SCREEN_WIDTH - 1);
                voltage_sr_i(SCREEN_WIDTH-1) <= adc_data;
            end if;
        end if;
    end process;
    voltage_sr <= voltage_sr_i;

end Behavioral;