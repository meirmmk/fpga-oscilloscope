library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

use work.bus_types_sizes.all;

entity vga_prep_tb is
end vga_prep_tb;

architecture tb of vga_prep_tb is

    signal voltage_data_bus : voltage_reg_t := (others => (others => '0'));
    signal vga_ready_y_reg  : vga_ready_y_reg_t;

    -- Debug signals for waveform viewer
    signal adc0_debug : std_logic_vector(11 downto 0);
    signal adc1_debug : std_logic_vector(11 downto 0);
    signal adc2_debug : std_logic_vector(11 downto 0);
    signal adc3_debug : std_logic_vector(11 downto 0);

    signal y0_debug   : std_logic_vector(8 downto 0);
    signal y1_debug   : std_logic_vector(8 downto 0);
    signal y2_debug   : std_logic_vector(8 downto 0);
    signal y3_debug   : std_logic_vector(8 downto 0);

begin

    uut : entity work.vga_prep
        port map (
            voltage_data_bus => voltage_data_bus,
            vga_ready_y_reg  => vga_ready_y_reg
        );

    -- Expose array elements as normal wave signals
    adc0_debug <= voltage_data_bus(0);
    adc1_debug <= voltage_data_bus(1);
    adc2_debug <= voltage_data_bus(2);
    adc3_debug <= voltage_data_bus(3);

    y0_debug <= vga_ready_y_reg(0);
    y1_debug <= vga_ready_y_reg(1);
    y2_debug <= vga_ready_y_reg(2);
    y3_debug <= vga_ready_y_reg(3);

    stim_proc : process
    begin
        voltage_data_bus(0) <= x"000";
        voltage_data_bus(1) <= x"800";
        voltage_data_bus(2) <= x"FFF";
        voltage_data_bus(3) <= x"100";

        wait for 10 ns;

        assert unsigned(vga_ready_y_reg(0)) = 480
            report "ADC 0 should map to y = 480"
            severity error;

        assert unsigned(vga_ready_y_reg(1)) = 255
            report "ADC 2048 should map to y = 255"
            severity error;

        assert unsigned(vga_ready_y_reg(2)) = 0
            report "ADC 4095 should map to y = 0"
            severity error;

        assert unsigned(vga_ready_y_reg(3)) = 479
            report "ADC 256 should map to y = 479"
            severity error;

        report "All vga_prep tests passed." severity note;

        wait for 100 ns;
        wait;
    end process;

end tb;