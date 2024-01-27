library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity prescaler is
    generic( limit : integer := 1e8 - 1 );
    Port (
        clock: in std_logic;
        reset: in std_logic;
        firstGear: in std_logic;
        secondGear: in std_logic;
        clock_enable: out std_logic
    );
end entity;

architecture Behavioral of prescaler is
    signal internalLimit: integer := limit;
    signal speedFactor: integer := 1;
    signal count : integer range 0 to limit; 
    
begin
    --implementacija za hendlnje hitrosti, ko je speed = 1 se hitrost poveca za pol
    speedFactor <= 2 when firstGear = '1' and secondGear = '0' else
                   4 when firstGear = '0' and secondGear = '1' else
                   8 when firstGear = '1' and secondGear = '1' else
                   1;
                   
    internalLimit <= limit/speedFactor; --limit when speed = '0' else limit/4;
    
    prescaler_counter: process (clock)
    begin
        if rising_edge(clock) then
            if reset='1' then
                count <= 0;
            elsif count >= internalLimit then
                count <= 0;
                clock_enable <= '1';
            else
                count <= count + 1;
                clock_enable <= '0';
            end if;
        end if;
    end process;

end Behavioral;
