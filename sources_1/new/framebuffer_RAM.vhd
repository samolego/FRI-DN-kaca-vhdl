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

entity framebuffer_RAM is
    generic (
        height : integer; -- number of rows
        width : integer; -- number of columns
        height_bits : integer; -- number of bits for the height
        width_bits : integer -- number of bits for the width
    );
    port (
        clk : in std_logic;
        we : in std_logic;
        -- pisanje - zapisemo celoten 16x16 sprite (reshaped v 256-bitni vektor)
        addr_writeY : in std_logic_vector (height_bits - 1 downto 0);
        addr_writeX : in std_logic_vector (width_bits - 1 downto 0);
        sprite2write : in std_logic_vector (256 - 1 downto 0);
        -- branje
        addr_readY : in std_logic_vector (height_bits - 1 downto 0);
        addr_readX : in std_logic_vector (width_bits - 1 downto 0);
        data_read : out std_logic
    );
end entity;
architecture Behavioral of framebuffer_RAM is

    constant sprite_width : integer := 16;

    -- Let's declare an array of words (array of pixel rows)
    -- The leftmost bit in a row has the index 0  
    type RAM_vrstice is array(0 to width - 1) of std_logic;
    type RAM_type is array(0 to height - 1) of RAM_vrstice;

    signal RAM : RAM_type;

    signal x_write: integer range 0 to width - 1;
    signal y_write: integer range 0 to height - 1;

begin
    -- asynchronous reading
    data_read <= RAM(to_integer(unsigned(addr_readY)))(to_integer(unsigned(addr_readX)));

    -- synchronous writing
    SYNC_PROC : process (clk)
    begin
        if rising_edge(clk) then
            if we = '1' then
                -- RAM(to_integer(unsigned(addr_writeY)))(to_integer(unsigned(addr_writeX))) <= sprite2write;

                -- write sprite to RAM
                x_write <= to_integer(unsigned(addr_writeX));
                y_write <= to_integer(unsigned(addr_writeY));

                for i in 0 to 255 loop
                    RAM(y_write + i / 16)(x_write + i mod 16) <= sprite2write(i);
                end loop;
            end if;
        end if;
    end process;
end Behavioral;