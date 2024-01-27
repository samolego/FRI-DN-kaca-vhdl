----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/16/2023 03:03:26 PM
-- Design Name: 
-- Module Name: top - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

USE ieee.std_logic_1164.ALL;

USE ieee.math_real.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity value_to_digit is
  Port (
    anode: in unsigned(7 downto 0);
    value: in unsigned(31 downto 0);
    digit: out unsigned(3 downto 0);
    characterCoded: out std_logic
  );
end entity;

architecture Behavioral of value_to_digit is

    signal sc: integer range 0 to 28;
    signal digitmp: unsigned(31 downto 0);

begin
    -- anoda = 1011
    -- -> želimo število za 8 šift v desno in mask z 0F
    -- Recept:
    -- 1. invert
    -- 1011 => 0100
    -- 2. log2
    -- log2(0100) => 2
    -- 3. dobljeno * 4
    -- 4. value >> dobljeno

    -- Težava: nimamo log2 ... se lotimo "grdo":
    with anode select sc <=
        0  when "11111110",
        4  when "11111101",
        8  when "11111011",
        12 when "11110111",
        16 when "11101111",
        20 when "11011111",
        24 when "10111111",
        28 when "01111111",
        0  when others;
   
    digitmp <= value srl sc;
    digit <= digitmp(3 downto 0);

-- moja resitev (FILIP)
--    index <=   0  when anode(0) = '0' else
--              4  when anode(1) = '0' else
--              8  when anode(2) = '0' else
--              12 when anode(3) = '0' else
--              16 when anode(4) = '0' else
--              20 when anode(5) = '0' else
--              24 when anode(6) = '0' else
--              28; --when antena(7) = '0' 
--    digit <= value(index+3 downto index);

    --signal, ki bo povedal da se nahajamo v zadnjih 4ih stevkah
    characterCoded <= '1' when anode(4) = '0' or anode(5) = '0' or anode(6) = '0' or anode(7) = '0' else '0';

end Behavioral;
