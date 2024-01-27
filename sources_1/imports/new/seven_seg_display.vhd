library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity seven_seg_display is
  Port (
    value: in unsigned(31 downto 0);
    clock: in std_logic;
    reset: in std_logic;
    cathode: out unsigned(6 downto 0);
    anode: out unsigned(7 downto 0);
    game_over: in std_logic 
  );
end entity;

architecture Behavioral of seven_seg_display is

    signal ce: std_logic := '0';
    signal digit: unsigned(3 downto 0) := "0000";
    signal anode_in: unsigned(7 downto 0) := "11111110";
    --signali za izpis GAME OVER 
    signal ceOneSec : std_logic;
    signal characterCoded : std_logic := '0';
    signal GAME : unsigned(15 downto 0) := "0000000100100011"; --0123
    signal OVER : unsigned(15 downto 0) := "0100010101100111"; --4567
    signal SCORE : unsigned(15 downto 0);
    signal GAMEandScore : unsigned(31 downto 0) := (others => '0'); 
    signal OVERandScore : unsigned(31 downto 0) := (others => '0');
    signal showGame : std_logic :='1';
    signal GOvalue : unsigned(31 downto 0) := (others => '0');
    signal oneSecond: integer := 1e8;
begin
    anode <= anode_in;
    
    SCORE <= value(15 downto 0);
    GAMEandScore <= GAME & SCORE when game_over = '1' else value;
    OVERandScore <= OVER & SCORE when game_over = '1' else value;
     -- proces ki menja napis GAME in OVER na vsako sekundo, ko je game over signal aktiven
    process(clock)
    begin
        if rising_edge(clock) then
            if reset='1' then
                GOvalue <= (others => '0');
            else
                --izpisujemo game over napis
                if game_over='1' then
                    if ceOneSec ='1' then
                        if showGame='1' then
                            GOvalue <= GAMEandScore;
                            showGame <= '0';
                        else
                            GOvalue <= OVERandScore;
                            showGame <= '1';
                        end if;
                    end if;
                else
                -- normalno
                    GOvalue <= value;
                end if;
            end if;
        end if;
    end process;
    
    
    prescalerForAnodes: entity work.prescaler(Behavioral) 
    generic map(limit => 5000) --od kje 500?
    port map(
        clock => clock,
        reset => reset,
        clock_enable => ce
    );
    
    prescalerOneSec: entity work.prescaler(Behavioral)
    generic map (limit => oneSecond)--ze po defaultu na eno sekundo
    port map (
        clock        => clock,
        reset        => reset,
        clock_enable => ceOneSec
    );
    
    anodeSelect: entity work.anode_select(Behavioral)
    port map(
        clock => clock,
        ce => ce,
        reset => reset,
        anode => anode_in
    );
    
    valueToDigit: entity work.value_to_digit(Behavioral)
    port map(
        anode => anode_in,
        value => GOvalue,
        digit => digit,
        characterCoded => characterCoded
    );
    
    digitToSegments: entity work.digit_to_segments(Behavioral)
    port map(
        digit => digit,
        cathode => cathode,
        characterCoded => characterCoded,
        displayGameOver => game_over
    );


end Behavioral;
