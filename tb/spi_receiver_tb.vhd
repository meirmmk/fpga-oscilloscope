--=============================================================
--Ben Dobbins
--CS56/ENGS31 21S
--This script is the testbench code for Lab 4, the voltmeter.
--=============================================================
--=============================================================
--Library Declarations
--=============================================================
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.all;

 --=============================================================
--Testbench Entity Declaration
--=============================================================
ENTITY spi_receiver_tb IS
END spi_receiver_tb;

--=============================================================
--Testbench declarations
--=============================================================
ARCHITECTURE testbench OF spi_receiver_tb IS 
component system_clock_generator is
    generic (CLOCK_DIVIDER_RATIO : integer);
	port (
        input_clk_port		: in std_logic;
        system_clk_port	    : out std_logic;
		fwd_clk_port		: out std_logic);
end component;

component tick_generator is
	port (
		FREQUENCY_DIVIDER_RATIO : in integer;
		system_clk_port   : in  std_logic;
		tick_port		  : out std_logic);
end component;

component spi_receiver is
	generic(
		N_SHIFTS 			: integer);
	port(
		clk_port			: in  std_logic;	--1 MHz serial clock
    	 
		take_sample_port 	: in  std_logic;	--controller signals
		spi_cs_port		    : out std_logic;

		spi_s_data_port	    : in  std_logic;	--datapath signals
		adc_data_port		: out std_logic_vector(11 downto 0));
end component; 

--=============================================================
--Local Signal Declaration
--=============================================================
signal clk_ext          : std_logic := '0';
signal system_clk       : std_logic := '0';
signal spi_s_data       : std_logic := '0';
signal take_sample      : std_logic := '0';
signal spi_sclk         : std_logic := '0' ;
signal spi_cs           : std_logic := '1';
signal adc_data         : std_logic_vector(11 downto 0) := (others => '0');

-- Clock period definitions
constant clk_period     : time := 10 ns;		-- 100 MHz clock

-- Data definitions
constant TxData         : std_logic_vector(14 downto 0) := "000" & x"abc";
signal bit_count        : integer := 14;
	
BEGIN 

-- Instantiate the Unit Under Test (UUT) 
uut: spi_receiver
generic map(
	N_SHIFTS => 15)
port map(
	clk_port			=> system_clk,
	take_sample_port 	=> take_sample,
	spi_cs_port		    => spi_cs,
	spi_s_data_port	    => spi_s_data,
	adc_data_port		=> adc_data);	

clocking: system_clock_generator 
generic map(
	CLOCK_DIVIDER_RATIO => 100)
port map(
	input_clk_port 		=> clk_ext,
	system_clk_port 	=> system_clk,
	fwd_clk_port		=> spi_sclk);

tick_generation: tick_generator
port map( 
	FREQUENCY_DIVIDER_RATIO => 100000,
	system_clk_port 	=> system_clk,
	tick_port			=> take_sample);	

--=============================================================
--Timing:
--=============================================================		      
-- Clock process definitions
clk_process :process
begin
    clk_ext <= '0';
    wait for clk_period/2;
    clk_ext <= '1';
    wait for clk_period/2;
end process;

--=============================================================
--Stimulus Process:
--=============================================================		
--The testbench pretends to be the A/D converter
--The testbench is waiting for spi_sclk and spi_cs from the design
--The data line will be undefined until it receives these signals
--TxData is the internal register where a sample is stored
--Here, the sample loaded in TxData is: 000 1010 1011 1100
--Or abc. This process acts as the shift register in the ADC and sends
--abc one bit at a time to your shift register. 
--Your design is working properly if you recover abc in your adc_data register.
stim_proc: process(spi_sclk)
begin
if falling_edge(spi_sclk) then       -- clock data out on falling edge, MSB first		
    if spi_cs = '0' then		
        spi_s_data <= TxData(bit_count);
        if bit_count = 0 then bit_count <= 14;
        else bit_count <= bit_count - 1;
        end if;		
    else
        bit_count <= 14;
    end if;			
end if;
end process;
END;