-- ========================================================
-- Entity: voltmeter_top_level
-- Description:
-- ADC acquisition subsystem. Wraps the Lab 6 voltmeter design
-- (SPI communication with the PMOD ADC, seven-segment display,
-- push-button sampling-frequency control) and adds a chip-select
-- rising-edge detector that emits a one-clock new_data pulse
-- whenever a completed 12-bit ADC sample is available for the
-- oscilloscope display path.
-- ========================================================

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

--=============================================================
--Shell Entity Declaration
--=============================================================

entity voltmeter_top_level is
port (  
	clk_ext_port     	  : in  std_logic;						--ext 100 MHz clock
	spi_s_data_ext_port	  : in  std_logic;						--data in line
	mode_ext_port		  : in  std_logic;						--voltage/hex select
	
	new_data_ext		  : out std_logic;						--new data monopulse
	spi_cs_ext_port		  : out std_logic;						--chip select
	spi_sclk_ext_port	  : out std_logic;						--serial clock
	spi_trigger_ext_port  : out std_logic;						--for scope triggering
	
	seg_ext_port	      : out std_logic_vector(0 to 6);		--segment control
	dp_ext_port			  : out std_logic;						--decimal point control
	an_ext_port			  : out std_logic_vector(3 downto 0);   --digit control
	
	left_freq_button      : in std_logic;                       -- controls FREQUENCY_DIVIDER_RATIO
	right_freq_button     : in std_logic;                       -- controls FREQUENCY_DIVIDER_RATIO
	
	adc_data_ext_port     : out std_logic_vector(11 downto 0)   -- adc data out
	);  
	
end voltmeter_top_level; 

--=============================================================
--Architecture + Component Declarations
--=============================================================
architecture Behavioral of voltmeter_top_level is

--=============================================================
--Signal Declaration
--=============================================================
-- Internal chip-select: routed both off-chip to the ADC and to
-- the rising-edge detector for new-data pulse generation.
signal spi_cs_ext   : std_logic := '0';

--=============================================================
--Port Mapping + Processes:
--=============================================================
begin


lab6_top_inst : entity work.lab6_top_level
    port map (
    -- inputs
       clk_ext_port             => 	    clk_ext_port,			--ext 100 MHz clock
       spi_s_data_ext_port      => 	    spi_s_data_ext_port,  	--data in line
       mode_ext_port		    =>  	mode_ext_port,		    --voltage/hex select
	-- outputs
	   spi_cs_ext_port	        => 	    spi_cs_ext, 		--chip select
	   spi_sclk_ext_port	 	=>      spi_sclk_ext_port,	    --serial clock
	   spi_trigger_ext_port 	=> 		spi_trigger_ext_port,	--for scope triggering
	
	   seg_ext_port	            =>  	seg_ext_port,	     --segment control
	   dp_ext_port				=>      dp_ext_port, 	     --decimal point control
	   an_ext_port			    =>      an_ext_port,         --digit control
	   adc_data_ext_port        =>      adc_data_ext_port,    --12 bit adc data
	   
	   left_freq_button      =>    left_freq_button,                   -- controls FREQUENCY_DIVIDER_RATIO
	   right_freq_button     =>    right_freq_button                   -- controls FREQUENCY_DIVIDER_RATIO
    );

cs_rising_edge_inst : entity work.cs_rising_edge
    port map(
    -- inputs 
        clk                     =>      clk_ext_port,        --ext 100 MHz clock
        spi_cs                  =>      spi_cs_ext,          --chip select
    -- output 
        new_data                =>      new_data_ext         --new data monopulse
    );
    
spi_cs_ext_port <= spi_cs_ext;

    
end Behavioral; 