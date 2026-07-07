-- ========================================================
-- Entity: freq_ratio_controller
-- Description:
-- Push-button control of the oscilloscope sampling-frequency
-- setting. Raw button inputs are synchronized (2-stage),
-- debounced (10 ms), and mono-pulsed; each right/left press
-- increments/decrements freq_reg by FREQ_STEP, saturating at
-- MAX_FREQ / MIN_FREQ. The output feeds the tick generator's
-- frequency divider ratio.
-- ========================================================

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity freq_ratio_controller is
    port (
        clk              : in  std_logic;
        btn_left_raw     : in  std_logic;
        btn_right_raw    : in  std_logic;
        freq_out         : out integer
    );
end entity;

architecture behavior of freq_ratio_controller is

    constant DEFAULT_FREQ : unsigned(15 downto 0) := to_unsigned(20000, 16);
    constant MIN_FREQ     : unsigned(15 downto 0) := to_unsigned(1000, 16);
    constant MAX_FREQ     : unsigned(15 downto 0) := to_unsigned(60000, 16);
    constant FREQ_STEP    : unsigned(15 downto 0) := to_unsigned(2000, 16);

    -- Adjust for debounce time.
    -- If clk = 1 MHz, 10000 cycles = 10 ms.
    -- If clk = 100 MHz, 1000000 cycles = 10 ms.
    constant DEBOUNCE_COUNT_MAX : unsigned(19 downto 0) := to_unsigned(10000, 20);

    signal freq_reg : unsigned(15 downto 0) := DEFAULT_FREQ;

    signal left_sync1, left_sync2   : std_logic := '0';
    signal right_sync1, right_sync2 : std_logic := '0';

    signal left_stable, right_stable : std_logic := '0';
    signal left_prev, right_prev     : std_logic := '0';

    signal left_count, right_count : unsigned(19 downto 0) := (others => '0');

    signal left_pulse, right_pulse : std_logic := '0';

begin

    process(clk)
    begin
        if rising_edge(clk) then

            -- Synchronize raw buttons
            left_sync1  <= btn_left_raw;
            left_sync2  <= left_sync1;

            right_sync1 <= btn_right_raw;
            right_sync2 <= right_sync1;

            -- Debounce left button
            if left_sync2 = left_stable then
                left_count <= (others => '0');
            else
                if left_count = DEBOUNCE_COUNT_MAX then
                    left_stable <= left_sync2;
                    left_count  <= (others => '0');
                else
                    left_count <= left_count + 1;
                end if;
            end if;

            -- Debounce right button
            if right_sync2 = right_stable then
                right_count <= (others => '0');
            else
                if right_count = DEBOUNCE_COUNT_MAX then
                    right_stable <= right_sync2;
                    right_count  <= (others => '0');
                else
                    right_count <= right_count + 1;
                end if;
            end if;

            -- Monopulse / rising-edge detect
            left_pulse  <= left_stable  and not left_prev;
            right_pulse <= right_stable and not right_prev;

            left_prev   <= left_stable;
            right_prev  <= right_stable;

            -- Frequency control
            if right_pulse = '1' then
                if freq_reg <= MAX_FREQ - FREQ_STEP then
                    freq_reg <= freq_reg + FREQ_STEP;
                else
                    freq_reg <= MAX_FREQ;
                end if;

            elsif left_pulse = '1' then
                if freq_reg >= MIN_FREQ + FREQ_STEP then
                    freq_reg <= freq_reg - FREQ_STEP;
                else
                    freq_reg <= MIN_FREQ;
                end if;
            end if;

        end if;
    end process;

    freq_out <= to_integer(freq_reg);

end architecture;
