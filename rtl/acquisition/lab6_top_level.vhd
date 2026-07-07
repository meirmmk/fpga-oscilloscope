--=============================================================
-- Entity: lab6_top_level
-- Description:
-- Core ADC acquisition subsystem. Generates the 1 MHz system
-- clock, produces sampling ticks at a user-adjustable rate
-- (freq_ratio_controller), runs the SPI receiver to collect
-- 12-bit samples from the PMOD ADC, and drives the seven-segment
-- voltmeter display via a block-ROM code-to-voltage lookup.
--
-- Based on the ENGS 31 Lab 6 voltmeter template (Ben Dobbins,
-- Thayer School of Engineering); extended with the push-button
-- frequency controller and the 12-bit ADC data output port.
--=============================================================

--=============================================================
--Library Declarations
--=============================================================
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

--=============================================================
--Shell Entitity Declarations
--=============================================================
entity lab6_top_level is
port (  
	clk_ext_port     	  : in  std_logic;						--ext 100 MHz clock
	
	spi_cs_ext_port		  : out std_logic;						--chip select
	spi_sclk_ext_port	  : out std_logic;						--serial clock
	spi_s_data_ext_port	  : in  std_logic;						--data in line
	spi_trigger_ext_port  : out std_logic;						--for scope triggering
	
	mode_ext_port		  : in  std_logic;						--voltage/hex select
	seg_ext_port	      : out std_logic_vector(0 to 6);		--segment control
	dp_ext_port			  : out std_logic;						--decimal point control
	an_ext_port			  : out std_logic_vector(3 downto 0);   --digit control
	
	left_freq_button      : in std_logic;                       -- controls FREQUENCY_DIVIDER_RATIO
	right_freq_button     : in std_logic;                       -- controls FREQUENCY_DIVIDER_RATIO
	
	adc_data_ext_port     : out std_logic_vector(11 downto 0)); --12 bit adc data
end lab6_top_level; 

--=============================================================
--Architecture + Component Declarations
--=============================================================
architecture Behavioral of lab6_top_level is
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--System Clock Generation:
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
component system_clock_generator is
	generic (
	   CLOCK_DIVIDER_RATIO : integer);
    port (
        input_clk_port		: in  std_logic;
        system_clk_port	    : out std_logic;
		fwd_clk_port		: out std_logic);
end component;

--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--Frequency Ratio Controller:
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
component freq_ratio_controller is
    port (
        clk                 : in  std_logic;
        btn_left_raw		: in  std_logic;
        btn_right_raw	    : in std_logic;
		freq_out  		    : out integer);
end component;


--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--Sample Tick Generation
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
component tick_generator is
	port (
	    FREQUENCY_DIVIDER_RATIO : in integer;
		system_clk_port : in  std_logic;
		tick_port	    : out std_logic);
end component;

--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--Spi Reciever
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
component spi_receiver is
	generic(
		N_SHIFTS			: integer);
	port(
		clk_port			: in  std_logic;	--1 MHz serial clock
    	 
		take_sample_port 	: in  std_logic;	--controller signals
		spi_cs_port		    : out std_logic;

		spi_s_data_port	    : in  std_logic;	--datapath signals
		adc_data_port		: out std_logic_vector(11 downto 0));
end component;

--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--BROM
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
COMPONENT blk_mem_gen_0
    PORT (
        clka : IN STD_LOGIC;
        addra : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
        douta : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)  );
END COMPONENT;

--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--7 Segment Display
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
component mux7seg is
    Port ( clk_port 	: in  std_logic;						-- runs on a fast (1 MHz or so) clock
	       y3_port 	    : in  std_logic_vector (3 downto 0);	-- digits
		   y2_port 	    : in  std_logic_vector (3 downto 0);	-- digits
		   y1_port		: in  std_logic_vector (3 downto 0);	-- digits
           y0_port 	    : in  std_logic_vector (3 downto 0);	-- digits
           dp_set_port  : in  std_logic_vector(3 downto 0);     -- decimal points
		   
           seg_port 	: out std_logic_vector(0 to 6);			-- segments (a...g)
           dp_port 	    : out std_logic;						-- decimal point
           an_port 	    : out std_logic_vector (3 downto 0) );	-- anodes
end component;

--=============================================================
--Local Signal Declaration
--=============================================================
signal system_clk       : std_logic := '0';
signal take_sample      : std_logic := '0';                   
signal adc_data         : std_logic_vector(11 downto 0) := (others => '0');	-- A/D output
signal measured_voltage : std_logic_vector(15 downto 0) := (others => '0');	-- A/D output

signal y3: std_logic_vector(3 downto 0) := (others => '0');
signal y2: std_logic_vector(3 downto 0) := (others => '0');
signal y1: std_logic_vector(3 downto 0) := (others => '0');
signal y0: std_logic_vector(3 downto 0) := (others => '0');
signal an: std_logic_vector(3 downto 0) := (others => '1');

signal freq_ext : integer := 20000;

--=============================================================
--Port Mapping + Processes:
--=============================================================
begin
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--Timing:
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++		
clocking: system_clock_generator 
generic map(
	CLOCK_DIVIDER_RATIO => 100)               -- 100 MHz ext clock -> 1 MHz system clock
port map(
	input_clk_port 		=> clk_ext_port,
	system_clk_port 	=> system_clk,
	fwd_clk_port		=> spi_sclk_ext_port);

tick_generation: tick_generator
port map( 
    FREQUENCY_DIVIDER_RATIO  => freq_ext,
	system_clk_port 	=> system_clk,
	tick_port			=> take_sample);
spi_trigger_ext_port <= take_sample;

freq_controller: freq_ratio_controller
port map(
    clk =>  system_clk,
    btn_left_raw  => left_freq_button,
    btn_right_raw => right_freq_button,
    freq_out    => freq_ext);

--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--spi_receiver:
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
receiver: spi_receiver
generic map(
	N_SHIFTS => 15)
port map(
	clk_port			=> system_clk,
	take_sample_port 	=> take_sample,
	spi_cs_port		    => spi_cs_ext_port,
	spi_s_data_port	    => spi_s_data_ext_port,
	adc_data_port		=> adc_data);	

--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--Block Memory
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++    
adc_data_to_measured_voltage : blk_mem_gen_0
  PORT MAP (
    clka                => system_clk,
    addra               => adc_data,
    douta               => measured_voltage);

--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--Mux to 7-Seg
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--Switch between a Hex display on the 7-seg and the voltage.
display_select: process(mode_ext_port, measured_voltage, adc_data)
begin
    if mode_ext_port = '1' then
        y3 <= measured_voltage(15 downto 12);
        y2 <= measured_voltage(11 downto 8);
        y1 <= measured_voltage(7 downto 4);
        y0 <= measured_voltage(3 downto 0);
    else
        y3 <= "0000";
        y2 <= adc_data(11 downto 8);
        y1 <= adc_data(7 downto 4);
        y0 <= adc_data(3 downto 0);
    end if;
end process;

display: mux7seg port map( 
    clk_port 		=> system_clk,	       -- runs on the 1 MHz clock
    y3_port 		=> y3, 		        
    y2_port 		=> y2, 	
    y1_port 		=> y1, 		
    y0_port 		=> y0,		
    dp_set_port	    => "1000",   
    seg_port 		=> seg_ext_port,
    dp_port 		=> dp_ext_port,
    an_port 		=> an );	

digit_on_off: process(mode_ext_port, an)
begin
	an_ext_port <= an;
	if mode_ext_port = '0' then 
	   an_ext_port <= an OR "1000"; 
    end if;
end process;

adc_data_ext_port <= adc_data;
    
end Behavioral; 