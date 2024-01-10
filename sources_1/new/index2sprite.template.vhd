library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity index2sprite is
    port (
        sprite_index : in std_logic_vector (4 downto 0);
        sprite_image_bits : out std_logic_vector (0 to 255)
    );
end entity;
architecture Behavioral of index2sprite is

begin

    with sprite_index select sprite_image_bits <=
        -- {{ cases }}
        (others => '0') when others;

end Behavioral;