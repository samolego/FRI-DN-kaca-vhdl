library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity digit_to_segments is
  Port (
    digit: in unsigned(3 downto 0);
    cathode: out unsigned(6 downto 0);
     characterCoded : in std_logic;
     displayGameOver: in std_logic 
  );
end digit_to_segments;


architecture Behavioral of digit_to_segments is

--type SegmentsArray is array (integer range 0 to 15) of unsigned(6 downto 0); -- Define a type for the array of segments
--constant d2s: SegmentsArray := (
--    "1000000",       -- 0
--    "1111001",       -- 1
--    "0100100",       -- 2
--    "0110000",       -- 3
--    "0011001",       -- 4
--    "0010010",       -- 5
--    "0000010",       -- 6
--    "1111000",       -- 7
--    "0000000",       -- 8
--    "0010000",       -- 9
--    "0001000",       -- A
--    "0000011",       -- b
--    "1000110",       -- C
--    "0100001",       -- d
--    "0000110",       -- E
--    "0001110"        -- F
--);
--moja reitev (FILIP)
    signal digValue: integer;
    signal showGameOver : std_logic := '0';
    
begin
--    cathode <= d2s(to_integer(digit));

--moja reitev (FILIP)
    digValue <= TO_INTEGER(digit);
    showGameOver <= characterCoded and displayGameOver;
    
    cathode <= (0|1|2|3|4|5 => '0', others => '1')  when digValue = 0 and showGameOver = '0' else --0
               (1|2 => '0', others => '1')          when digValue = 1 and showGameOver = '0' else --1
               (0|1|6|4|3 => '0', others => '1')    when digValue = 2 and showGameOver = '0' else --2
               (0|1|6|2|3 => '0', others => '1')    when digValue = 3 and showGameOver = '0' else --3
               (1|2|6|5 => '0', others => '1')      when digValue = 4 and showGameOver = '0' else --4
               (0|5|6|2|3 => '0', others => '1')    when digValue = 5 and showGameOver = '0' else --5
               (0|5|6|4|3|2 => '0', others => '1')  when digValue = 6 and showGameOver = '0' else --6
               (0|1|2 => '0', others => '1')        when digValue = 7 and showGameOver = '0' else --7
               (0|1|2|3|4|5|6 => '0', others => '1')when digValue = 8 and showGameOver = '0' else --8
               (0|1|2|3|5|6 => '0', others => '1')  when digValue = 9 and showGameOver = '0' else --9
               (0|1|2|4|5|6 => '0', others => '1')  when digValue = 10 and showGameOver = '0' else --A 
               (5|6|4|3|2 => '0', others => '1')    when digValue = 11 and showGameOver = '0' else --B
               (0|5|4|3 => '0', others => '1')      when digValue = 12 and showGameOver = '0' else --C
               (1|2|3|4|6 => '0', others => '1')    when digValue = 13 and showGameOver = '0' else --D
               (0|3|4|5|6 => '0', others => '1')    when digValue = 14 and showGameOver = '0' else --E
               (0|5|6|4 => '0', others => '1')      when digValue = 15 and showGameOver = '0' else --F
               --napis GAME OVER, zakodiran kot G=0, A = 1..
               (0|5|6|4|3|2 => '0', others => '1')  when digValue = 0 and showGameOver = '1' else --G = 6
               (0|1|2|4|5|6 => '0', others => '1')  when digValue = 1 and showGameOver = '1' else --A
               (2|6|4 => '0', others => '1')        when digValue = 2 and showGameOver = '1' else --M
               (0|3|4|5|6 => '0', others => '1')    when digValue = 3 and showGameOver = '1' else --E
               (0|1|2|3|4|5 => '0', others => '1')  when digValue = 4 and showGameOver = '1' else --O = 0
               (1|2|3|4|5 => '0', others => '1')    when digValue = 5 and showGameOver = '1' else --V
               (0|3|4|5|6 => '0', others => '1')    when digValue = 6 and showGameOver = '1' else --E
               (4|6 => '0', others => '1')          when digValue = 7 and showGameOver = '1' --R
               ;
           
end Behavioral;
