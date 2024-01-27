library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity prescaler is
    generic( limit : integer := 1e8 - 1 );
    Port (
        clock: in std_logic;
        reset: in std_logic;
        clock_enable: out std_logic
    );
end entity;

architecture Behavioral of prescaler is

    signal count : integer range 0 to limit; 

begin
    prescaler_counter: process (clock)
    begin
        if rising_edge(clock) then
            if reset='1' then
                count <= 0;
            elsif count >= limit then
                count <= 0;
                clock_enable <= '1';
            else
                count <= count + 1;
                clock_enable <= '0';
            end if;
        end if;
    end process;

end Behavioral;
