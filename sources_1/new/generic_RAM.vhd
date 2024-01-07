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
entity generic_RAM is
    generic (
        height : integer; -- number of rows
        width : integer; -- number of columns
        height_bits : integer; -- number of bits for the height
        width_bits : integer; -- number of bits for the width
        word_size : integer := 8 -- number of bits in a word
    );
    port (
        clk : in std_logic;
        we : in std_logic;
        addr_writeY : in std_logic_vector (height_bits - 1 downto 0);
        addr_writeX : in std_logic_vector (width_bits - 1 downto 0);
        addr_readY : in std_logic_vector (height_bits - 1 downto 0);
        addr_readX : in std_logic_vector (width_bits - 1 downto 0);
        data_write : in std_logic_vector (word_size - 1 downto 0);
        data_read : out std_logic_vector (word_size - 1 downto 0)
    );
end entity;
architecture Behavioral of generic_RAM is
    -- Let's declare an array of words (array of pixel rows)
    -- The leftmost bit in a row has the index 0  
    type RAM_vrstice is array(0 to width - 1) of std_logic_vector(word_size - 1 downto 0);
    type RAM_type is array(0 to height - 1) of RAM_vrstice;

    signal RAM : RAM_type;
    -- If you want to initialize RAM content, use this line instead:
--    signal RAM : RAM_type := (others => (others => "1"));

begin
    -- asynchronous reading
    data_read <= RAM(to_integer(unsigned(addr_readY)))(to_integer(unsigned(addr_readX)));

    -- synchronous writing
    SYNC_PROC : process (clk)
    begin
        if rising_edge(clk) then
            if we = '1' then
                RAM(to_integer(unsigned(addr_writeY)))(to_integer(unsigned(addr_writeX))) <= data_write;
            end if;
        end if;
    end process;
end Behavioral;