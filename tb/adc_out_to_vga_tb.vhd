-- ========================================================
-- Entity: adc_out_to_vga_shell_tb
-- Description: Testbench for adc_out_to_vga_shell
-- ========================================================

-- **Library Declarations**
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.bus_types_sizes.ADC_DATA_WIDTH_C;

entity adc_out_to_vga_tb is
end entity;

architecture testbench of adc_out_to_vga_tb is

-- **Component Declaration**
component adc_out_to_vga_shell is
    port (
        ext_clk_port                    : in    STD_LOGIC;
        adc_data_port                   : in    STD_LOGIC_VECTOR(ADC_DATA_WIDTH_C-1 downto 0);
        shift_en_port                   : in    STD_LOGIC;
        red_port, green_port, blue_port : out   STD_LOGIC_VECTOR(3 downto 0);
        H_sync_port, V_sync_port        : out   STD_LOGIC
        );
end component adc_out_to_vga_shell;

-- **Signal Declarations**
signal clk_ext                      : STD_LOGIC := '0';
signal adc_data                     : STD_LOGIC_VECTOR(ADC_DATA_WIDTH_C-1 downto 0) := (others=>'0');
signal shift_en                     : STD_LOGIC := '0';
signal red_ext, green_ext, blue_ext : STD_LOGIC_VECTOR(3 downto 0) := "0000";
signal H_sync_ext, V_sync_ext       : STD_LOGIC := '0';
signal t_wavegen                    : UNSIGNED(ADC_DATA_WIDTH_C-1 downto 0) := (others=>'0');

begin

uut : adc_out_to_vga_shell
port map(
    ext_clk_port    => clk_ext,
    adc_data_port   => adc_data,
    shift_en_port   => shift_en, -- rising edge of the cs port on the spi receiver
    red_port        => red_ext,
    green_port      => green_ext,
    blue_port       => blue_ext,
    H_sync_port     => H_sync_ext,
    V_sync_port     => V_sync_ext
);

-- clockgen
clkgen : process
begin
    clk_ext <= '0';
    wait for 5 ns;
    clk_ext <= '1';
    wait for 5 ns;
end process clkgen;

-- voltage waveform generation
voltgen : process
begin
    -- voltage ramp input
    t_wavegen <= t_wavegen + 20;
    adc_data <= std_logic_vector(t_wavegen);
    shift_en <= '1';
    wait for 10 ns;
    shift_en <= '0';
    wait for 1 ms;
end process voltgen;



end architecture;