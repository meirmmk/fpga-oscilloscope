-- ========================================================
-- Entity: vga_sync
-- Description:
-- Generates all timing for a 640x480 @ 60 Hz VGA display from
-- the 100 MHz system clock: a 25 MHz pixel-clock enable,
-- horizontal/vertical sync pulses, the video_on visible-region
-- flag, current pixel coordinates, and a one-clock
-- load_new_screen pulse at the end of each visible frame
-- (used by the framebuffer to update tear-free).
-- Timing constants follow the standard VGA specification.
-- ========================================================

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

ENTITY vga_sync IS
    generic (
        -- size of x and y coordinate data
        X_SIZE : integer := 10;
        Y_SIZE : integer := 9
    );
    port ( 	
        clk		            :   in  STD_LOGIC; --100 MHz clock
        V_sync	            :   out	STD_LOGIC;
        H_sync	            :   out	STD_LOGIC;
        video_on            :   out	STD_LOGIC;
        load_new_screen     :   out STD_LOGIC; 
        pixel_x	            :   out	STD_LOGIC_VECTOR(X_SIZE-1 downto 0);
        pixel_y             :   out	STD_LOGIC_VECTOR(Y_SIZE-1 downto 0)
    );
end vga_sync;

architecture behavior of vga_sync is

signal H_video_on       : STD_LOGIC := '0';
signal V_video_on       : STD_LOGIC := '0';
signal V_video_on_prev  : STD_LOGIC := '0';

-- clkgen
signal PCLK         : STD_LOGIC := '0';
signal PCLK_timer   : STD_LOGIC := '0'; 
signal PCLK_prev    : STD_LOGIC := '0';
signal PCLK_rising  : STD_LOGIC := '0';

-- line timing
signal hsweep_start : STD_LOGIC := '0';

signal pxl_cnt  : UNSIGNED(9 downto 0) := (others=>'0'); -- 0 t0 799
signal line_cnt : UNSIGNED(9 downto 0) := (others=>'0'); -- 0 to 520
-- line_cnt needs to be 10 bits instead of 9 (like pixel_y) because it can be bigger than 512

--VGA Constants (taken directly from VGA Class Notes)

constant left_border    : integer := 48;
constant h_display      : integer := 640;
constant right_border   : integer := 16;
constant h_retrace      : integer := 96;
constant HSCAN          : integer := left_border + h_display + right_border + h_retrace - 1; --number of PCLKs in an H_sync period

constant top_border     : integer := 29;
constant v_display      : integer := 480;
constant bottom_border  : integer := 10;
constant v_retrace      : integer := 2;
constant VSCAN          : integer := top_border + v_display + bottom_border + v_retrace - 1; --number of H_syncs in an V_sync period

BEGIN

--PCLK Generating Process
PCLK_proc : process(clk)
begin
	if rising_edge(clk) then
        PCLK_prev <= PCLK;
        PCLK_timer <= not(PCLK_timer);
        
        if PCLK_timer='0' then
            PCLK <= not(PCLK);
        end if;
    end if;
end process PCLK_proc;

--H_sync generating process
Hsync_proc : process(clk)
begin
    if rising_edge(clk) then
        if PCLK_rising='1' then
            -- incremement pixel count
            pxl_cnt <= pxl_cnt+1 when pxl_cnt < HSCAN else (others=>'0');
        end if;
    end if;
end process Hsync_proc;

-- line counting process
line_cnt_proc : process(clk)
begin
    if rising_edge(clk) then
        if PCLK_rising = '1' then
            if hsweep_start='1' then
                line_cnt <= line_cnt+1 when line_cnt < VSCAN else (others=>'0');
            end if;
        end if;
    end if;
end process line_cnt_proc;

-- monopulsed signal on falling edge of V_video_on to detect when we can put new data into the framebuffer
detect_new_screen : process(clk)
begin
    if rising_edge(clk) then
        V_video_on_prev <= V_video_on;
    end if;
end process detect_new_screen;
load_new_screen <=  '1' when V_video_on='0' and V_video_on_prev='1' else '0';

-- asynchronous outputs
async_proc : process(PCLK_prev, PCLK, pxl_cnt, line_cnt, H_video_on, V_video_on)
begin
    -- rising edges
    PCLK_rising     <= '1' when (PCLK_prev='0' and PCLK='1') else '0';
    hsweep_start    <= '1' when pxl_cnt=HSCAN else '0';

    -- horizontal outputs
    H_video_on      <= '1' when pxl_cnt < h_display else '0';
    H_sync          <= '1' when pxl_cnt < h_display+right_border or h_display+right_border+h_retrace < pxl_cnt else '0';
    
    -- vertical outputs
    V_video_on      <= '1' when line_cnt < v_display else '0';
    V_sync          <= '1' when line_cnt < v_display+bottom_border or v_display+bottom_border+v_retrace < line_cnt else '0';

    --Only enable video out when H_video_out and V_video_out are high. 
    -- It's important to set the output to zero when you aren't actively displaying video. 
    -- That's how the monitor determines the black level.
    video_on <= H_video_on AND V_video_on; 

    -- determine pixel_x and pixel_y
    if  H_video_on and V_video_on then
        pixel_x <= std_logic_vector(pxl_cnt (X_SIZE-1 downto 0));
        pixel_y <= std_logic_vector(line_cnt(Y_SIZE-1 downto 0));
    else
        pixel_x <= (others=>'0');
        pixel_y <= (others=>'0');
    end if;

end process async_proc;

end behavior;
        
        