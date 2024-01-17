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
    digit: out unsigned(3 downto 0)
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


end Behavioral;
