-- package declarations
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.NUMERIC_STD.all;

-- testbench declaration
use work.bus_types_sizes.vga_ready_y_reg_t;
use work.bus_types_sizes.X_SIZE;
use work.bus_types_sizes.Y_SIZE;

entity framebuffer_tb is
end entity framebuffer_tb;

architecture testbench of framebuffer_tb is

-- **Component Declarations**
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
end component;

-- use the vga_sync to drive the x and y pixel values
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
end component vga_sync;

-- **Signals and constants**

-- different screens to display
constant y_reg_in1  : vga_ready_y_reg_t    := (  2       => std_logic_vector(to_unsigned(200, 9)), 
                                                    others  => std_logic_vector(to_unsigned(0  , 9)));
constant y_reg_in2  : vga_ready_y_reg_t    := (  3   => std_logic_vector(to_unsigned(100, 9)),
                                                    400 => std_logic_vector(to_unsigned(20, 9)), 
                                                    others=>(others=>'0'));

signal clk              : STD_LOGIC := '0';

signal y_reg_in             : vga_ready_y_reg_t    := (others=>(others=>'0'));
signal pixel_x              : STD_LOGIC_VECTOR(X_SIZE-1 downto 0)  := (others=>'0');
signal pixel_y              : STD_LOGIC_VECTOR(Y_SIZE-1 downto 0)  := (others=>'0');
signal video_on             : STD_LOGIC := '0';
signal load_new_screen      : STD_LOGIC := '0';
signal red, green, blue     : STD_LOGIC_VECTOR(3 downto 0)  := "0000";

begin

uut : framebuffer port map (
    clk                 => clk,
    y_reg_in            => y_reg_in,
    pixel_x             => pixel_x,
    pixel_y             => pixel_y,
    video_on            => video_on,
    load_new_screen     => load_new_screen,
    red                 => red,
    green               => green,
    blue                => blue
);

vga_sync_inst: vga_sync
port map(
    clk                 => clk,
    V_sync              => open,
    H_sync              => open,
    video_on            => video_on,
    load_new_screen     => load_new_screen,
    pixel_x             => pixel_x,
    pixel_y             => pixel_y
);

clkgen  : process
begin
    clk <= '0'; 
    wait for 2 ns; 
    clk <= '1'; 
    wait for 2 ns;
end process clkgen;

stim_proc : process
begin
    -- Show empty screen

    -- change to screen 1
    wait until load_new_screen='0';
    y_reg_in <= y_reg_in1;

    --  load in screen 2 while screen 1 is being shown

    wait for 5 ms;
    y_reg_in <= y_reg_in2;

end process stim_proc;

end architecture;