library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity framebuffer_RAM2 is
    generic (
        height : integer; -- number of rows
        width : integer; -- number of columns
        screen_height : integer; -- number of pixels in a column
        screen_width : integer -- number of pixels in a row
    );
    port (
        clk : in std_logic;
        display_we : in std_logic;
        -- pisanje - zapisemo index sprita, naslovi so okrnjeni (niso po pixlih, temvec po spritih)
        addr_writeY : in integer range 0 to height - 1;
        addr_writeX : in integer range 0 to width - 1;
        -- sprite index
        sprite_idx2write : in std_logic_vector (4 downto 0);
        -- branje (pozor. tu pa gre za prave naslove)
        addr_readY : in integer range 0 to screen_height - 1;
        addr_readX : in integer range 0 to screen_width - 1;
        display_bit_read : out std_logic
    );
end entity;
architecture Behavioral of framebuffer_RAM2 is

    constant sprite_size : integer := 16;

    signal read_sprite_idx : std_logic_vector (4 downto 0);
    signal sprite_image_vector : std_logic_vector (0 to 255);
begin

    display_bit_read <= sprite_image_vector((addr_readY mod sprite_size) * sprite_size + addr_readX mod sprite_size);

    index2sprite : entity work.index2sprite(Behavioral)
        port map(
            sprite_index => read_sprite_idx,
            sprite_image_bits => sprite_image_vector
        );

    ram : entity work.generic_RAM(Behavioral)
        generic map(
            width => width,
            height => height,
            word_size => 5,
            default_value => '0'
        )
        port map(
            clk => clk,
            we => display_we,
            addr_writeY => addr_writeY,
            addr_writeX => addr_writeX,
            -- ko beremo, beremo po spritih (ne po pixlih), zato delimo s sprite_size
            addr_readY => addr_readY / sprite_size,
            addr_readX => addr_readX / sprite_size,
            data_write => sprite_idx2write,
            data_read => read_sprite_idx
        );
end Behavioral;