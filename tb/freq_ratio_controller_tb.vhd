library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity freq_ratio_controller_tb is
end entity;

architecture testbench of freq_ratio_controller_tb is

    component freq_ratio_controller is
        port (
            clk             : in  STD_LOGIC;
            btn_left_pulse  : in  STD_LOGIC;
            btn_right_pulse : in  STD_LOGIC;
            freq_out        : out integer
        );
    end component;

    signal clk             : STD_LOGIC := '0';
    signal btn_left_pulse  : STD_LOGIC := '0';
    signal btn_right_pulse : STD_LOGIC := '0';
    signal freq_out        : integer;

    constant CLK_PERIOD : time := 10 ns;

begin

    DUT : freq_ratio_controller
        port map (
            clk             => clk,
            btn_left_pulse  => btn_left_pulse,
            btn_right_pulse => btn_right_pulse,
            freq_out        => freq_out
        );

    -- Clock generation
    clk_process : process
    begin
        while true loop
            clk <= '0';
            wait for CLK_PERIOD / 2;
            clk <= '1';
            wait for CLK_PERIOD / 2;
        end loop;
    end process;

    -- Stimulus
    stim_proc : process
    begin

        -- Start at default frequency
        wait for 3 * CLK_PERIOD;

        -- Press right button 3 times
        btn_right_pulse <= '1';
        wait for CLK_PERIOD;
        btn_right_pulse <= '0';
        wait for 2 * CLK_PERIOD;

        btn_right_pulse <= '1';
        wait for CLK_PERIOD;
        btn_right_pulse <= '0';
        wait for 2 * CLK_PERIOD;

        btn_right_pulse <= '1';
        wait for CLK_PERIOD;
        btn_right_pulse <= '0';
        wait for 4 * CLK_PERIOD;

        -- Press left button 2 times
        btn_left_pulse <= '1';
        wait for CLK_PERIOD;
        btn_left_pulse <= '0';
        wait for 2 * CLK_PERIOD;

        btn_left_pulse <= '1';
        wait for CLK_PERIOD;
        btn_left_pulse <= '0';
        wait for 5 * CLK_PERIOD;

        -- End simulation
        assert false report "Simulation finished." severity failure;

    end process;

end architecture;