library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity digit_to_segments is
  Port (
    digit: in unsigned(3 downto 0);
    cathode: out unsigned(6 downto 0)
  );
end digit_to_segments;


architecture Behavioral of digit_to_segments is

type SegmentsArray is array (integer range 0 to 15) of unsigned(6 downto 0); -- Define a type for the array of segments

constant d2s: SegmentsArray := (
    "1000000",       -- 0
    "1111001",       -- 1
    "0100100",       -- 2
    "0110000",       -- 3
    "0011001",       -- 4
    "0010010",       -- 5
    "0000010",       -- 6
    "1111000",       -- 7
    "0000000",       -- 8
    "0010000",       -- 9
    "0001000",       -- A
    "0000011",       -- b
    "1000110",       -- C
    "0100001",       -- d
    "0000110",       -- E
    "0001110"        -- F
);

begin

    cathode <= d2s(to_integer(digit));

end Behavioral;
