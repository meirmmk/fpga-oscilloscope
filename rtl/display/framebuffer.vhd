-- ========================================================
-- Entity: framebuffer
-- Description:
-- Generates the RGB output for every pixel. A buffer register
-- holds one full screen of waveform y-coordinates and is updated
-- only on load_new_screen (between frames) to prevent tearing.
-- For each pixel: draws the waveform (green) where the stored
-- y-coordinate matches, static gridlines at 0/±3/±6 V (grey),
-- and small LUT-sprite voltage labels (white); black elsewhere.
-- ========================================================

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
use work.bus_types_sizes.vga_ready_y_reg_t;
use work.bus_types_sizes.Y_DATA_WIDTH_C;
use work.bus_types_sizes.SCREEN_WIDTH;

entity framebuffer is
    generic (
        -- size of x and y coordinate data
        X_SIZE : integer := 10;
        Y_SIZE : integer := 9
    );
    port (
        clk                 : in    STD_LOGIC;
        y_reg_in            : in    vga_ready_y_reg_t;
        pixel_x             : in    STD_LOGIC_VECTOR(X_SIZE-1 downto 0);
        pixel_y             : in    STD_LOGIC_VECTOR(Y_SIZE-1 downto 0);
        video_on            : in    STD_LOGIC;
        load_new_screen     : in    STD_LOGIC;
        red, green, blue    : out   STD_LOGIC_VECTOR(3 downto 0)
    );
end entity;

architecture behavior of framebuffer is

-- need a buffer register to stay static while the screen is on and only write the new data between screens
signal y_reg_buffer     : vga_ready_y_reg_t := (others=>(others=>'0'));
signal y_at_x           : STD_LOGIC_VECTOR(Y_SIZE-1 downto 0) := (others=>'0');
signal coord_match      : STD_LOGIC := '0';

signal pixel_x_int      : integer := to_integer(unsigned(pixel_x));
signal pixel_y_int      : integer := to_integer(unsigned(pixel_y));

-- Gridline vertical positions: 0 V midline and ±3 V / ±6 V at 80-pixel spacing
constant line_0V         : integer := 241;
constant line_3V         : integer := line_0V  - 80;
constant line_3V_neg     : integer := line_0V  + 80;
constant line_6V         : integer := line_0V  - 2 * 80;
constant line_6V_neg     : integer := line_0V  + 2 * 80;

type label_rom_type is array (0 to 4)of std_logic_vector(2 downto 0);
type label_rom_type_z is array (0 to 4)of std_logic_vector(6 downto 0);

constant Label_0 : label_rom_type_z := (
"1110101",
"1010101",
"1010101",
"1010101",
"1110010"
);

constant Label_3 : label_rom_type := (
"111",
"001",
"111",
"001",
"111"
);

constant Label_6 : label_rom_type := (
"111",
"100",
"111",
"101",
"111"
);

begin

-- write to y_reg buffer when V_video is down
write_to_buffer_reg : process(clk)
begin
    if rising_edge(clk) then
        y_reg_buffer <= y_reg_in when load_new_screen='1';
    end if;
end process write_to_buffer_reg;


-- read vga pin values
color_readout : process(all)
begin
    -- only show a white pixel at (read_x, read_y), y_reg_buffer(read_x) = read_y, and only if video is on, otherwise show black pixel
    red     <= "0000"; 
    green   <= "0000"; 
    blue    <= "0000";
    coord_match <= '0';
    
    if video_on='1' and unsigned(pixel_x) < 640 then -- second condition avoids pixel_x briefly flashing as 640 and causing OOB error
    
    pixel_x_int <= to_integer(unsigned(pixel_x));
    pixel_y_int <= to_integer(unsigned(pixel_y));
    
        -- horizontal lines
        if (pixel_y_int = line_0V ) 
        or (pixel_y_int = line_3V ) 
        or (pixel_y_int = line_6V )
        or (pixel_y_int = line_3V_neg )
        or (pixel_y_int = line_6V_neg ) then
            red     <= "0100"; 
            green   <= "0100"; 
            blue    <= "0100";
        end if;
        
        -- horizontal voltage display
        -- 0V
        if ((pixel_x >= std_logic_vector(to_unsigned(3, 10)) and pixel_x < std_logic_vector(to_unsigned(10, 10))) and 
            (pixel_y >= std_logic_vector(to_unsigned(line_0V + 3, 9)) and pixel_y < std_logic_vector(to_unsigned(line_0V + 8, 9)))) then
            
            if Label_0(pixel_y_int - line_0V - 3)(9 - pixel_x_int) = '1' then 
                red     <= "1000"; 
                green   <= "1000"; 
                blue    <= "1000";
            end if;
        end if;
        
        -- -3V
        if (pixel_y_int = line_3V_neg + 5) and (pixel_x_int < 5) and (pixel_x_int > 2) then 
            red     <= "1000"; 
            green   <= "1000"; 
            blue    <= "1000";
        end if;
        if ((pixel_x >= std_logic_vector(to_unsigned(6, 10)) and pixel_x < std_logic_vector(to_unsigned(9, 10))) and 
            (pixel_y >= std_logic_vector(to_unsigned(line_3V_neg + 3, 9)) and pixel_y < std_logic_vector(to_unsigned(line_3V_neg + 8, 9)))) then
            
            if (Label_3(pixel_y_int - line_3V_neg - 3)(8 - pixel_x_int) = '1') then 
                red     <= "1000"; 
                green   <= "1000"; 
                blue    <= "1000";
            end if;
        end if;
        
        -- 3V
        if ((pixel_x >= std_logic_vector(to_unsigned(3, 10)) and pixel_x < std_logic_vector(to_unsigned(6, 10))) and 
            (pixel_y >= std_logic_vector(to_unsigned(line_3V + 3, 9)) and pixel_y < std_logic_vector(to_unsigned(line_3V + 8, 9)))) then
            
            if Label_3(pixel_y_int - line_3V - 3)(5 - pixel_x_int) = '1' then 
                red     <= "1000"; 
                green   <= "1000"; 
                blue    <= "1000";
            end if;
        end if;
        
        -- -6V
        if (pixel_y_int = line_6V_neg + 5) and (pixel_x_int < 5) and (pixel_x_int > 2) then 
            red     <= "1000"; 
            green   <= "1000"; 
            blue    <= "1000";
        end if;
        if ((pixel_x >= std_logic_vector(to_unsigned(6, 10)) and pixel_x < std_logic_vector(to_unsigned(9, 10))) and 
            (pixel_y >= std_logic_vector(to_unsigned(line_6V_neg + 3, 9)) and pixel_y < std_logic_vector(to_unsigned(line_6V_neg + 8, 9)))) then
            
            if Label_6(pixel_y_int - line_6V_neg - 3)(8 - pixel_x_int) = '1' then 
                red     <= "1000"; 
                green   <= "1000"; 
                blue    <= "1000";
            end if;
        end if;
        
        -- 6V
        if ((pixel_x >= std_logic_vector(to_unsigned(3, 10)) and pixel_x < std_logic_vector(to_unsigned(6, 10))) and 
            (pixel_y >= std_logic_vector(to_unsigned(line_6V + 3, 9)) and pixel_y < std_logic_vector(to_unsigned(line_6V + 8, 9)))) then
            
            if Label_6(pixel_y_int - line_6V - 3)(5 - pixel_x_int) = '1' then 
                red     <= "1000"; 
                green   <= "1000"; 
                blue    <= "1000";
            end if;
        end if;

    
        y_at_x <= y_reg_buffer(to_integer(unsigned(pixel_x)));
        coord_match <= '1' when y_at_x = pixel_y else '0';
        if coord_match='1' then
            red     <= "0000"; 
            green   <= "1111"; 
            blue    <= "0000";
        end if;
    end if;
    
    
end process color_readout;

end architecture;