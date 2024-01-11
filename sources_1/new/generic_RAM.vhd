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
        word_size : integer := 8; -- number of bits in a word
        default_value : std_logic := '1'
    );
    port (
        clk : in std_logic;
        we : in std_logic;
        -- writing
        addr_writeY : in integer range 0 to height - 1;
        addr_writeX : in integer range 0 to width - 1;
        data_write : in std_logic_vector (word_size - 1 downto 0);
        -- reading
        addr_readY : in integer range 0 to height - 1;
        addr_readX : in integer range 0 to width - 1;
        data_read : out std_logic_vector (word_size - 1 downto 0)
    );
end entity;
architecture Behavioral of generic_RAM is
    -- Let's declare an array of words (array of pixel rows)
    -- The leftmost bit in a row has the index 0  
    type RAM_vrstice is array(0 to width - 1) of std_logic_vector(word_size - 1 downto 0);
    type RAM_type is array(0 to height - 1) of RAM_vrstice;

    -- If you want to initialize RAM content, use this line instead:
    signal RAM : RAM_type := (others => (others => (others => default_value)));

begin
    -- asynchronous reading
    data_read <= RAM(addr_readY)(addr_readX);

    -- synchronous writing
    SYNC_PROC : process (clk)
    begin
        if rising_edge(clk) then
            if we = '1' then
                RAM(addr_writeY)(addr_writeX) <= data_write;
            end if;
        end if;
    end process;
end Behavioral;