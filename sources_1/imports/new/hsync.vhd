----------------------------------------------------------------------------------
-- Projekt: Krmilnik za VGA
-- Modul za vodoravno sinhronizacijo
-- Verzija: 2023-11-15
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.all;

entity hsync is
    Port ( 
        clock : in  STD_LOGIC;
        reset : in  STD_LOGIC;
        clock_enable : out STD_LOGIC;
        display_area : inout STD_LOGIC;
        column       : out natural range 0 to 639;
        hsync : out STD_LOGIC);
end entity;

architecture Behavioral of hsync is

------------------------------------------------
-- DEKLARACIJE KONSTANT
------------------------------------------------
constant T  : integer := 800 * 4; -- perioda signala hsync
constant SP : integer := 96 * 4;  -- Ä?as, da se tuljava izprazni
constant FP : integer := 16 * 4;  -- front porch
constant BP : integer := 48 * 4;  -- back porch

------------------------------------------------
-- DEKLARACIJE NOTRANJIH SIGNALOV
------------------------------------------------
-- Register za stevec, mora biti vsaj 12 biten, da lahko steje do 3199.
-- Samo za referenco: moÅ¾ni naÄ?ini doloÄ?anja zaÄ?etne vrednosti
--signal count : std_logic_vector(11 downto 0) := "000000000000";    -- binarno
--signal count : std_logic_vector(11 downto 0) := X"0";              -- Å¡estnajstiÅ¡ko
--signal count : std_logic_vector(11 downto 0) := ('0','0','0',...); -- tabela bitov
--signal count : std_logic_vector(11 downto 0) := (8=>'0', 10=>'0', 11=>'0',...); -- asociativna tabela oblike indeks => vrednost 
--signal count : std_logic_vector(11 downto 0) := (11 | 10 | 9 => '0', others => '0'); -- zdruÅ¾evanje indeksov, beseda others pomeni "vsi ostali nenavedeni" 
--signal count : unsigned(11 downto 0) := (others => '0');
-- Raje delamo s celimi Å¡tevili (desetiÅ¡ko)
signal count : integer range 0 to T-1 := 0;
signal sync_on : std_logic := '0';
signal sync_off : std_logic := '0';
signal reset_cnt : std_logic := '0';
signal q : std_logic := '0';

begin

------------------------------------------------
-- VZPOREDNI STAVKI
-- Za opis odloÄ?itvenih vezij 
-- prirejanje:  <= 
-- pogojno prirejanje: when-else, with-select
------------------------------------------------
        
    -- primerjalnika za SP in T
    sync_on  <= '1' when count = SP-1 else '0';
    sync_off <= '1' when count = T-2 else '0';
    --sync_off <= '1' when count = 3135 else '0';
    
    --mogo?e potrebno rešiti s procesom
    
    -- preslikava stanja pomnilne celice na izhod
    hsync <= q;
    
    --preslikava clock enable, ki oznaÄ?uje konec vrstice
    clock_enable <= sync_off;
    
    --prejsnja (asinhrona) verzija
    reset_cnt <= '1' when reset = '1' OR sync_off = '1'  else '0'; --OR (count = 3135)
    display_area <= '1' when count >= (SP + BP) AND count < (T - FP) else '0';
    --column <= (count - SP - BP) / 4 when display_area ='1' else 0;
    
--    process(reset, sync_off, count)
--    begin
--    -- signal za reset
--    -- reset_cnt <= reset =  OR sync_off OR (count = 3133);
--    if reset = '1' OR sync_off = '1' OR count = 3136 then
--        reset_cnt <= '1';
--    else 
--        reset_cnt <= '0';
--    end if;
    
--    -- Ali smo v obmoÄ?ju prikaza slike (display area)?
--    -- V tem obmoÄ?ju lahko priÅ¾gemo elektronske topove.
--    if count >= (SP + BP) AND count < (T - FP) then
--        display_area <= '1';
--    else
--        display_area <= '0';
--    end if;
    
--    -- Na osnovi Å¡tevca urinih period izraÄ?unamo indeks stolpca v obmoÄ?ju prikaza slike (raster 640 x 480)
----    if display_area ='1' then
----        column <= (count - SP - BP) / 4;
----    else
----        column <= 0;
----    end if;
    
--    end process;
    
    counter: process (clock)
    begin
        
        ------------------------------------------------
        -- ZAPOREDNI STAVKI - samo znotraj procesa
        -- Za opis odloÄ?itvenih in sekvenÄ?nih vezij 
        -- prirejanje:  <= 
        -- prirejanje spremenljivk / zaÄ?etnih vrednosti:   :=
        -- stavki: if, for, case 
        ------------------------------------------------        
        if rising_edge(clock) then
      
            -- Sinhron reset, aktivno visok
            if reset_cnt = '1' then
                count <= 0;
            else
                count <= count + 1;
            end if;
        -- To je Å¾e implicitno res
        --else 
        --    count <= count; -- ohranjaj stanje
        
            if display_area ='1' then
                column <= (count - SP - BP) / 4;
            else
                column <= 0;
            end if;
            
        end if;
    end process;
    
    SR_FF: process (clock)
    begin            
        if rising_edge(clock) then
            -- Sinhron reset, aktivno visok
            if reset = '1' then
                q <= '0';
            elsif sync_on = '1' then
                q <= '1';
            elsif sync_off = '1' then
                q <= '0';                      
            end if;
        
        end if;
    end process;

end Behavioral;
