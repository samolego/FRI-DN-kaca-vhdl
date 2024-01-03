library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
entity sprite2index is
    generic (
        sprite_vector_width : integer -- length of sprite matrix reshaped into vector
    );
    port (
        clk : in std_logic;
        sprite_index : in integer;
        sprite_image_bits : out std_logic_vector (sprite_vector_width - 1 downto 0)
    );
end entity;
architecture Behavioral of sprite2index is

begin

    get_image_bits : process (clk)
    begin
        if rising_edge(clk) then
            case sprite_index is
                -- {{ whens }}
                when others =>
                    sprite_image_bits <= (others => '0');
            end case;
        end if;
    end process;

end Behavioral;