----------------------------------------------------------------------------------------
-- RAM: 32 rows of 40 bits
-- Simple dual-port: 
--     - simultaneous reading and writing
--     - asynchronous reads: we get data on dataOut immediately after valid addrOut
--     - synchronous writes: data on dataIn are being written at address addrIn 
--                           on a rising edge of the clock and active write-enable (we) 
-- Example: VGA frame buffer
--     - simplification: 30x40 is a 1/16 of the original VGA resolution 480x640
--     - we will declare 32x40 bits RAM but will use only rows 0 to 29
--     - caution: a row is oriented in LSB -> MSB fashion to better model a screen, 
--       where the top-leftmost pixel has an index of 0.
-----------------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity framebuffer_RAM2 is
    generic (
        height : integer; -- number of rows
        width : integer -- number of columns
    );
    port (
        clk : in std_logic;
        we : in std_logic;
        -- pisanje - zapisemo celoten 16x16 sprite (reshaped v 256-bitni vektor)
        addr_writeY : in integer range 0 to height - 1;
        addr_writeX : in integer range 0 to width - 1;
        sprite_idx2write : in std_logic_vector (4 downto 0);
        -- branje
        addr_readY : in integer range 0 to height - 1;
        addr_readX : in integer range 0 to width - 1;
        data_read : out std_logic
    );
end entity;
architecture Behavioral of framebuffer_RAM2 is

    constant sprite_size : integer := 16;

    signal read_sprite_idx : std_logic_vector (4 downto 0);
    signal sprite_image_vector : std_logic_vector (255 downto 0);

    signal scaled_write_x : integer range 0 to width / sprite_size - 1;
    signal scaled_write_y : integer range 0 to height / sprite_size - 1;
    signal scaled_read_x : integer range 0 to width / sprite_size - 1;
    signal scaled_read_y : integer range 0 to height / sprite_size - 1;


begin

    data_read <= sprite_image_vector((addr_readY mod sprite_size) * sprite_size + addr_readX mod sprite_size);

    index2sprite : entity work.index2sprite(Behavioral)
        port map(
            sprite_index => read_sprite_idx,
            sprite_image_bits => sprite_image_vector
        );
    

    scaled_read_x <= addr_readX / sprite_size;
    scaled_read_y <= addr_readY / sprite_size;
    scaled_write_x <= addr_writeX / sprite_size;
    scaled_write_y <= addr_writeY / sprite_size;

    ram : entity work.generic_RAM(Behavioral)
        generic map(
            width => width,
            height => height,
            word_size => 5,
            default_value => '1'
        )
        port map(
            clk => clk,
            we => we,
            addr_writeY => scaled_write_y,
            addr_writeX => scaled_write_x,
            addr_readY => scaled_read_y,
            addr_readX => scaled_read_x,
            data_write => sprite_idx2write,
            data_read => read_sprite_idx
        );
end Behavioral;