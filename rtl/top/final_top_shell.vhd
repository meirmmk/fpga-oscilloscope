-- ========================================================
-- Entity: final_top_shell
-- Description:
-- Top level of the FPGA oscilloscope. Integrates the ADC
-- acquisition subsystem (voltmeter_top_level), which produces
-- 12-bit ADC samples and a new-data pulse, with the VGA display
-- subsystem (adc_out_to_vga_shell), which buffers samples and
-- renders the waveform on a 640x480 VGA monitor.
-- Target: Digilent Basys 3 (Artix-7), 100 MHz system clock
-- ========================================================

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

use work.bus_types_sizes.ADC_DATA_WIDTH_C;

entity final_top_shell is
port (
    clk_ext     	  : in  std_logic;         -- 100 MHz clock
    spi_s_data_ext	  : in  std_logic;			--data in line
    mode_ext		  : in  std_logic;			--voltage/hex select
    
    left_freq_button_ext        : in std_logic;     -- controlling time axis
    right_freq_button_ext       : in std_logic;     -- controlling time axis
    
    spi_cs_ext_port		  : out std_logic;						--chip select
	spi_sclk_ext_port	  : out std_logic;						--serial clock
	spi_trigger_ext_port  : out std_logic;						--for scope triggering
	
	seg_ext_port	      : out std_logic_vector(0 to 6);		 --segment control
	dp_ext_port			  : out std_logic;						 --decimal point control
	an_ext_port			  : out std_logic_vector(3 downto 0);    --digit control

    H_sync_ext          : out std_logic;
    V_sync_ext          : out std_logic;

    vga_red_ext         : out std_logic_vector(3 downto 0);
    vga_green_ext       : out std_logic_vector(3 downto 0);
    vga_blue_ext        : out std_logic_vector(3 downto 0)
);

end entity;

architecture shell of final_top_shell is

-- **Component Declarations**
component adc_out_to_vga_shell is
    port (
        ext_clk_port                    : in    STD_LOGIC;
        adc_data_port                   : in    STD_LOGIC_VECTOR(ADC_DATA_WIDTH_C-1 downto 0);
        shift_en_port                   : in    STD_LOGIC;
        red_port                        : out   STD_LOGIC_VECTOR(3 downto 0);
        green_port                      : out   STD_LOGIC_VECTOR(3 downto 0);
        blue_port                       : out   STD_LOGIC_VECTOR(3 downto 0);
        H_sync_port                     : out   STD_LOGIC;
        V_sync_port                     : out   STD_LOGIC
        );
end component adc_out_to_vga_shell;

component voltmeter_top_level is
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
	
end component; 

signal shift_enable_ext : std_logic := '0';
signal adc_data_ext : std_logic_vector(11 downto 0);

-- Block wiring
begin

    Voltmeter_top_inst : voltmeter_top_level
    port map (
    -- inputs
       clk_ext_port             => 	    clk_ext,			--ext 100 MHz clock
       spi_s_data_ext_port      => 	    spi_s_data_ext,  	--data in line
       mode_ext_port		    =>  	mode_ext,			--voltage/hex select
	-- outputs
	   new_data_ext             =>      shift_enable_ext,        -- new data monopulse
	   spi_cs_ext_port	        => 	    spi_cs_ext_port, 	     --chip select
	   spi_sclk_ext_port	 	=>      spi_sclk_ext_port,	     --serial clock
	   spi_trigger_ext_port 	=> 		spi_trigger_ext_port,    --for scope triggering
	
	   seg_ext_port	            =>  	seg_ext_port,	        --segment control
	   dp_ext_port				=>      dp_ext_port, 	        --decimal point control
	   an_ext_port			    =>      an_ext_port,            --digit control
	   
	   left_freq_button         =>      left_freq_button_ext,
	   right_freq_button        =>      right_freq_button_ext,
	   	   
	   adc_data_ext_port        =>      adc_data_ext            --12 bit adc data
    );

    VGA_top_inst : adc_out_to_vga_shell
    port map (
    -- inputs 
        ext_clk_port            =>      clk_ext,        --ext 100 MHz clock             
        adc_data_port           =>      adc_data_ext,              
        shift_en_port           =>      shift_enable_ext, 
    -- ouputs               
        red_port                =>      vga_red_ext, 
        green_port              =>      vga_green_ext,
        blue_port               =>      vga_blue_ext,
        H_sync_port             =>      H_sync_ext,
        V_sync_port             =>      V_sync_ext
    );

end architecture;