----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/16/2023 03:06:26 PM
-- Design Name: 
-- Module Name: seven_seg_display - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity seven_seg_display is
  Port (
    value: in unsigned(31 downto 0);
    clock: in std_logic;
    reset: in std_logic;
    cathode: out unsigned(6 downto 0);
    anode: out unsigned(7 downto 0)
  );
end entity;

architecture Behavioral of seven_seg_display is

    signal ce: std_logic := '0';
    signal digit: unsigned(3 downto 0) := "0000";
    signal anode_in: unsigned(7 downto 0) := "11111110";

begin

    anode <= anode_in;

    pr: entity work.prescaler(Behavioral)
    generic map(limit => 500)
    port map(
        clock => clock,
        reset => reset,
        clock_enable => ce
    );
    
    an_s: entity work.anode_select(Behavioral)
    port map(
        clock => clock,
        ce => ce,
        reset => reset,
        anode => anode_in
    );
    
    v2d: entity work.value_to_digit(Behavioral)
    port map(
        anode => anode_in,
        value => value,
        digit => digit
    );
    
    d2s: entity work.digit_to_segments(Behavioral)
    port map(
        digit => digit,
        cathode => cathode
    );


end Behavioral;
