--=============================================================
-- Entity: spi_receiver
-- Description:
-- SPI communication with the PMOD ADC. A four-state FSM
-- (idle / assert_cs / shifting / load_data) drives chip-select
-- and shifts N_SHIFTS serial bits into a 12-bit register on the
-- 1 MHz serial clock, then loads the completed sample onto
-- adc_data_port.
--
-- Based on the ENGS 31 Lab 6 SPI receiver template (Ben Dobbins,
-- Thayer School of Engineering); FSM completed by S. Demick,
-- M. Karataikyzy, H. Wang.
--=============================================================

--=============================================================
--Library Declarations
--=============================================================
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

--=============================================================
--Entitity Declarations
--=============================================================
entity spi_receiver is
	generic(
		N_SHIFTS 				: integer);
	port(
	    --1 MHz serial clock
		clk_port				: in  std_logic;	
    	
    	--controller signals
		take_sample_port 		: in  std_logic;	
		spi_cs_port			    : out std_logic;
        
        --datapath signals
		spi_s_data_port		    : in  std_logic;	
		adc_data_port			: out std_logic_vector(11 downto 0));
end spi_receiver; 

--=============================================================
--Architecture + Component Declarations
--=============================================================
architecture Behavioral of spi_receiver is
--=============================================================
--Local Signal Declaration
--=============================================================
signal shift_enable		: std_logic := '0';
signal load_enable		: std_logic := '0';
signal shift_reg	    : std_logic_vector(11 downto 0) := (others => '0');

type state is (idle, assert_cs, shifting, load_data);
signal current_state : state := idle;
signal next_state    : state := idle;

signal shift_count : unsigned(3 downto 0) := (others => '0');

begin
--=============================================================
--Controller:
--=============================================================

--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--State Update:
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++		
state_update: process(clk_port)
begin
    if rising_edge(clk_port) then
        current_state <= next_state;
    end if;
end process;

--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--Next State Logic:
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
next_state_logic: process(current_state, take_sample_port, shift_count)
begin
    next_state <= current_state;

    case current_state is

        when idle =>
            if take_sample_port = '1' then
                next_state <= assert_cs;
            else
                next_state <= idle;
            end if;

        when assert_cs =>
            next_state <= shifting;

        when shifting =>
            if shift_count = to_unsigned(N_SHIFTS - 1, 4) then
                next_state <= load_data;
            else
                next_state <= shifting;
            end if;

        when load_data =>
            next_state <= idle;

        when others =>
            next_state <= idle;

    end case;
end process;

--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--Output Logic:
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
output_logic: process(current_state)
begin
    spi_cs_port  <= '1';
    shift_enable <= '0';
    load_enable  <= '0';

    case current_state is

        when idle =>
            spi_cs_port  <= '1';
            shift_enable <= '0';
            load_enable  <= '0';

        when assert_cs =>
            spi_cs_port  <= '0';
            shift_enable <= '1';
            load_enable  <= '0';

        when shifting =>
            spi_cs_port  <= '0';
            shift_enable <= '1';
            load_enable  <= '0';

        when load_data =>
            spi_cs_port  <= '1';
            shift_enable <= '0';
            load_enable  <= '1';

        when others =>
            spi_cs_port  <= '1';
            shift_enable <= '0';
            load_enable  <= '0';

    end case;
end process;

--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--Timer Sub-routine:
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
shift_counter: process(clk_port)
begin
    if rising_edge(clk_port) then
        if current_state = idle then
            shift_count <= (others => '0');

        elsif current_state = assert_cs or current_state = shifting then
            if shift_count < to_unsigned(N_SHIFTS - 1, 4) then
                shift_count <= shift_count + 1;
            end if;
        end if;
    end if;
end process;

--=============================================================
--Datapath:
--=============================================================
shift_register: process(clk_port) 
begin
	if rising_edge(clk_port) then
		if shift_enable = '1' then shift_reg <= shift_reg(10 downto 0) & spi_s_data_port;
		end if;
		
		if load_enable = '1' then adc_data_port <= shift_reg;
		end if;
    end if;
end process;
end Behavioral; 


