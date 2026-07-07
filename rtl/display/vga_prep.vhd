-- ========================================================
-- Entity: vga_prep
-- Description:
-- Combinational block which receives a 640-deep shift-register
-- bus of 12-bit voltage values and outputs a 640-deep register
-- bus of 9-bit y-values to be plotted on the screen over VGA.
-- Each sample is downsized to its 9 MSBs, inverted so larger
-- voltages appear higher on screen, and clamped to the visible
-- 480-line region.
-- ========================================================

-- **Library Declarations**
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;			

-- Custom array buses and sizes
use work.bus_types_sizes.voltage_reg_t;
use work.bus_types_sizes.vga_ready_y_reg_t;
use work.bus_types_sizes.ADC_DATA_WIDTH_C;
use work.bus_types_sizes.Y_DATA_WIDTH_C;
use work.bus_types_sizes.Y_SIZE;
use work.bus_types_sizes.SCREEN_WIDTH;
use work.bus_types_sizes.SCREEN_HEIGHT;

entity vga_prep is
    Port (
        voltage_data_bus    : in voltage_reg_t;
        vga_ready_y_reg     : out vga_ready_y_reg_t
    );
end vga_prep;

architecture Behavioral of vga_prep is

-- **Signal Declarations**
type reg_9bit_t is array (0 to SCREEN_WIDTH-1) of STD_LOGIC_VECTOR(Y_DATA_WIDTH_C-1 downto 0);

signal reg_downsized_flipped : reg_9bit_t := (others=>(others=>'0'));

begin
    downsize_flip_clamp : process(voltage_data_bus, reg_downsized_flipped)
    begin
        for idx in 0 to SCREEN_WIDTH-1 loop
            -- downsize to 9 bits and flip across y=256 by simply inverting all bits
            reg_downsized_flipped(idx) <= not(voltage_data_bus(idx)(ADC_DATA_WIDTH_C-1 downto 3));

            -- clamp to [0, 480)
            vga_ready_y_reg(idx) <= 
                reg_downsized_flipped(idx) when unsigned(reg_downsized_flipped(idx)) < to_unsigned(SCREEN_HEIGHT, Y_SIZE) else 
                STD_LOGIC_VECTOR(to_unsigned(SCREEN_HEIGHT, Y_SIZE));
        end loop;
    end process downsize_flip_clamp;
end Behavioral;