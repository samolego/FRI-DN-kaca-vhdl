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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity anode_select is
  Port (
    clock: in std_logic;
    ce: in std_logic;
    reset: in std_logic;
    anode: out unsigned(7 downto 0)
  );
end entity;

architecture Behavioral of anode_select is

    constant FIRST_ANODE: unsigned(7 downto 0) := "11111110";
    
    signal anode_vec: unsigned(7 downto 0) := FIRST_ANODE;

begin
    anode <= anode_vec;
    
    rotator: process(clock, reset, ce)
    begin
        if rising_edge(clock) then
            if reset = '1' then
                anode_vec <= FIRST_ANODE;
            end if;
            
            -- sicer pa rotiramo če lahko
            if ce = '1' then
                -- rotacija v levo
                anode_vec <= anode_vec(6 downto 0) & anode_vec(7);
            end if;
        end if;
    
    end process;


end Behavioral;
