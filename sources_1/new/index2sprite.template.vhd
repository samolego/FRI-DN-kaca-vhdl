library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity index2sprite is
    generic (
        sprite_vector_width : integer -- length of sprite matrix reshaped into vector
    );
    port (
        sprite_index : in integer;
        sprite_image_bits : out std_logic_vector (sprite_vector_width - 1 downto 0)
    );
end entity;
architecture Behavioral of index2sprite is

begin

    with sprite_index select sprite_image_bits <=
        -- {{ cases }}
        (others => '0') when others;

end Behavioral;