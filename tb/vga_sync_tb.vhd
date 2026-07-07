library IEEE;
use IEEE.std_logic_1164.all;
use work.bus_types_sizes.X_SIZE;
use work.bus_types_sizes.Y_SIZE;

entity vga_sync_tb is
end vga_sync_tb;

architecture testbench of vga_sync_tb is

component vga_sync IS
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



signal 	clk		        :	STD_LOGIC; --100 MHz clock
signal	V_sync	        : 	STD_LOGIC;
signal	H_sync	        : 	STD_LOGIC;
signal	video_on        :	STD_LOGIC;
signal  V_video_on      :   STD_LOGIC;
signal	pixel_x	        :	STD_LOGIC_VECTOR(X_SIZE-1 downto 0);
signal	pixel_y	        :	STD_LOGIC_VECTOR(Y_SIZE-1 downto 0);


begin
uut : vga_sync PORT MAP(
		clk             => CLK,
		V_sync          => V_sync,
        H_sync          => H_sync,
        Video_on        => video_on,
        load_new_screen => V_video_on,
		pixel_x         => pixel_x,
        pixel_y         => pixel_y);
    
clk_proc : process
BEGIN
    CLK <= '0';
    wait for 5 ns;   
    CLK <= '1';
    wait for 5 ns;
END PROCESS clk_proc;

stim_proc : process
begin
    wait;
end process stim_proc;

end testbench;