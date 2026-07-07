library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

use work.bus_types_sizes.voltage_reg_t;
use work.bus_types_sizes.ADC_DATA_WIDTH_C;

entity adc_data_shiftreg_tb is
end adc_data_shiftreg_tb;

architecture testbench of adc_data_shiftreg_tb is

    signal clk            : std_logic := '0';
    signal adc_data       : std_logic_vector(ADC_DATA_WIDTH_C - 1 downto 0) := (others => '0');
    signal shift_en       : std_logic := '0';
    signal voltage_sr     : voltage_reg_t;

    constant clk_period : time := 10 ns;

begin

    -- Unit under test
    uut : entity work.adc_data_shiftreg
        port map (
            clk            => clk,
            adc_data       => adc_data,
            shift_en       => shift_en,
            voltage_sr     => voltage_sr
        );

    -- Clock generation
    clk_process : process
    begin
        while true loop
            clk <= '0';
            wait for clk_period / 2;
            clk <= '1';
            wait for clk_period / 2;
        end loop;
    end process;

    -- Stimulus process
    stim_process : process
    begin
        wait for 20 ns;

        -- Start shifting ADC data into the register
        shift_en <= '1';

        adc_data <= "000000000000"; -- 0
        wait for clk_period;

        adc_data <= "000000001000"; -- 8
        wait for clk_period;

        adc_data <= "000000010000"; -- 16
        wait for clk_period;

        adc_data <= "000000100000"; -- 32
        wait for clk_period;

        adc_data <= "111000000000"; -- 3584
        wait for 50 * clk_period;

        -- Disable shifting
        -- This value should NOT enter the shift register
        shift_en <= '0';
        adc_data <= "111111111111"; -- 4095
        wait for 3 * clk_period;

        -- Re-enable shifting
        shift_en <= '1';

        adc_data <= "000001000000"; -- 64
        wait for clk_period;

        adc_data <= "000010000000"; -- 128
        wait for 50 * clk_period;

        shift_en <= '0';

        wait for 50 ns;

        assert false report "Simulation finished" severity failure;
    end process;

end testbench;
