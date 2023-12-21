----------------------------------------------------------------------------------
-- Projekt: Krmilnik za VGA
-- Modul za navpično sinhronizacijo
-- Verzija: 2023-11-15
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;


entity vsync is
    Port ( 
        clock : in  STD_LOGIC;
        reset : in  STD_LOGIC;
        clock_enable : in STD_LOGIC;
        display_area : inout STD_LOGIC;
        row          : out natural range 0 to 479;
        vsync : out STD_LOGIC);
end entity;

architecture Behavioral of vsync is

------------------------------------------------
-- DEKLARACIJE KONSTANT
------------------------------------------------
constant T  : integer := 521; -- število vrstic skupaj
constant SP : integer := 2;  -- čas, da se tuljava izprazni
constant FP : integer := 10;  -- front porch
constant BP : integer := 29;  -- back porch

------------------------------------------------
-- DEKLARACIJE NOTRANJIH SIGNALOV
------------------------------------------------
signal count : integer range 0 to T-1 := 0;
signal sync_on : std_logic := '0';
signal sync_off : std_logic := '0';
signal reset_cnt : std_logic := '0';
signal q : std_logic := '0';

begin
        
    -- primerjalnika za SP in T
    sync_on  <= '1' when count = SP-1 and clock_enable='1' else '0';
    sync_off <= '1' when count = T-1 and clock_enable='1' else '0';
    
    -- signal za reset
    reset_cnt <= reset OR sync_off;
    
    -- preslikava stanja pomnilne celice na izhod
    vsync <= q;
    
    -- Ali smo v območju prikaza slike (display area)?
    -- V tem območju lahko prižgemo elektronske topove.
    display_area <= '1' when count >= (SP + BP) AND count < (T - FP) else '0';
    
    -- Na osnovi števca vrstic izračunamo indeks vrstice v območju prikaza slike (raster 640 x 480)
    row <= (count - SP - BP) when display_area ='1' else 0;
       
    counter: process (clock)
    begin      
        if rising_edge(clock) then
            -- Sinhron reset, aktivno visok
            if reset_cnt = '1' then
                count <= 0;
            else
                if clock_enable = '1' then
                    count <= count + 1; -- prištej eno vrstico
                end if;
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
