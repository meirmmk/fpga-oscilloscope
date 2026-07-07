-- ========================================================
-- Entity: adc_out_to_vga_shell
-- Description: 
-- Receives a 12-bit voltage reading from the ADC/SPI
-- receiver and a signal for when each measurement is complete. Saves these 
-- datapoints to a register and manipulates the data in some way, then prepares 
-- the manipulated data to be sent to VGA. Outputs the pin values for the VGA port.
-- ========================================================

-- **Library Declarations**
library ieee;
use ieee.std_logic_1164.all;
use work.bus_types_sizes.voltage_reg_t;
use work.bus_types_sizes.vga_ready_y_reg_t;
use work.bus_types_sizes.ADC_DATA_WIDTH_C;
use work.bus_types_sizes.X_SIZE;
use work.bus_types_sizes.Y_SIZE;

entity adc_out_to_vga_shell is
    port (
        ext_clk_port                    : in    STD_LOGIC;
        adc_data_port                   : in    STD_LOGIC_VECTOR(ADC_DATA_WIDTH_C-1 downto 0);
        shift_en_port                   : in    STD_LOGIC;
        red_port, green_port, blue_port : out   STD_LOGIC_VECTOR(3 downto 0);
        H_sync_port, V_sync_port        : out   STD_LOGIC
        );
end entity;

architecture shell of adc_out_to_vga_shell is

-- **Component Declarations**

-- takes adc data and saves to a shift register
-- this was split off from adc_data_prep in order to have a data bus 
-- of only voltage values available so we can do things like fft or
--  different scrolling modes
component adc_data_shiftreg is
    Port (
        clk                 : in  std_logic;
        adc_data            : in  std_logic_vector(ADC_DATA_WIDTH_C-1 downto 0);
        shift_en            : in  std_logic;
        voltage_sr          : out voltage_reg_t
    );
end component adc_data_shiftreg;

-- Combinatorial block which prepares a 12-bit voltage-valued register into a 9-bit y-valued 
-- register to be sent to framebuffer
component vga_prep is
    Port (
        voltage_data_bus    : in voltage_reg_t;
        vga_ready_y_reg     : out vga_ready_y_reg_t
    );
end component vga_prep;

-- takes in screen-valid y-values (origin at (0,0), contained in the interval [0, 480)) and 
-- the sync controls, outputs the RGB vectors for the VGA port.
component framebuffer is
    port (
        clk                 : in    STD_LOGIC;
        y_reg_in            : in    vga_ready_y_reg_t;
        pixel_x             : in    STD_LOGIC_VECTOR(X_SIZE-1 downto 0);
        pixel_y             : in    STD_LOGIC_VECTOR(Y_SIZE-1 downto 0);
        video_on            : in    STD_LOGIC;
        load_new_screen     : in    STD_LOGIC;
        red, green, blue    : out   STD_LOGIC_VECTOR(3 downto 0)
    );
end component framebuffer;

-- controls timing of vga sweeps
component vga_sync is
    PORT ( 	
        clk		        :   in  STD_LOGIC; --100 MHz clock
        V_sync	        :   out	STD_LOGIC;
        H_sync	        :   out	STD_LOGIC;
        video_on        :   out	STD_LOGIC;
        load_new_screen :   out STD_LOGIC; 
        pixel_x	        :   out	STD_LOGIC_VECTOR(X_SIZE-1 downto 0);
        pixel_y         :   out	STD_LOGIC_VECTOR(Y_SIZE-1 downto 0)
        );
end component;


-- **Signal Declarations**
signal voltage_data_bus : voltage_reg_t := (others=>(others=>'0'));
signal y_bus            : vga_ready_y_reg_t := (others=>(others=>'0'));
signal video_on         : STD_LOGIC := '0';
signal load_new_screen  : STD_LOGIC := '0';
signal pixel_x          : STD_LOGIC_VECTOR(X_SIZE-1 downto 0);
signal pixel_y          : STD_LOGIC_VECTOR(Y_SIZE-1 downto 0);

begin
    
adc_data_shiftreg_inst: adc_data_shiftreg
port map(
    clk         => ext_clk_port,
    adc_data    => adc_data_port,
    shift_en    => shift_en_port,
    voltage_sr  => voltage_data_bus
);

vga_prep_inst: vga_prep
port map(
    voltage_data_bus    => voltage_data_bus,
    vga_ready_y_reg     => y_bus
);

framebuffer_inst: framebuffer
port map(
    clk                 => ext_clk_port,
    y_reg_in            => y_bus,
    pixel_x             => pixel_x,
    pixel_y             => pixel_y,
    video_on            => video_on,
    load_new_screen     => load_new_screen,
    red                 => red_port,
    green               => green_port,
    blue                => blue_port
);

vga_sync_inst: vga_sync
port map(
    clk                 => ext_clk_port,
    V_sync              => V_sync_port,
    H_sync              => H_sync_port,
    video_on            => video_on,
    load_new_screen     => load_new_screen,
    pixel_x             => pixel_x,
    pixel_y             => pixel_y
);

end architecture;

