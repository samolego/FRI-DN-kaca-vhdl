----------------------------------------------------------------------------------
-- Krmilnik za VGA - glavni modul
-- verzija: 2023-11-15
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_1164.all;

entity vgaController is
    Port ( CLK100MHZ : in STD_LOGIC;
           CPU_RESETN : in STD_LOGIC;
           data       : in STD_LOGIC_VECTOR(255 downto 0);
           VGA_HS : out STD_LOGIC;
           VGA_VS : out STD_LOGIC;
           VGA_R  : out STD_LOGIC_VECTOR(3 downto 0);
           VGA_G  : out STD_LOGIC_VECTOR(3 downto 0);
           VGA_B  : out STD_LOGIC_VECTOR(3 downto 0)
           );
end vgaController;

architecture Behavioral of vgaController is

signal CE : std_logic;
signal rst : std_logic;
signal display_area_h : std_logic;
signal display_area_v : std_logic;
signal display_area   : std_logic;
signal column : natural range 0 to 639;
signal row    : natural range 0 to 479;

--tabela, ki steje katero vrstico sprita na data bomo izrisali
type twoDimArray is array (natural range <>, natural range <>) of natural range 0 to 15;
signal row_counters : twoDimArray(0 to 39, 0 to 29);

signal sprite_addr_row : natural range 0 to 29;
signal sprite_addr_col : natural range 0 to 39;
signal rowIndex : natural range 0 to 15;
signal upperLimit : natural range 255 to 0;
signal lowerLimit : natural range 255 to 0;

signal dataChunk: std_logic_vector(15 downto 0);
signal shiftData: std_logic := '1';
signal presc : natural range 0 to 4 := 0;
signal dataChunkCount : natural range 0 to 15;
signal bitValue: std_logic;
signal bitVector: std_logic_vector(3 downto 0) := "0000";

begin
    rst <= not CPU_RESETN;
    
    -- Povezovanje komponent: modula hsync in vsync
    hsync: entity work.hsync
    port map(
        clock => CLK100MHZ, 
        reset => rst,
        clock_enable => CE,
        display_area => display_area_h,
        column => column,
        hsync => VGA_HS
    );
    
    vsync: entity work.vsync
    port map(
        clock => CLK100MHZ, 
        reset => rst,
        clock_enable => CE,
        display_area => display_area_v,
        row => row, 
        vsync => VGA_VS
    );
    
    -- Logika za prižig elektronskih topov (signali RGB)
    display_area <= display_area_h AND display_area_v;
    
    process (data, display_area, row, column)
    begin
        if display_area='1' then
            -- v dataChunk zapi�emo novo vrstico
            if shiftData = '1' then
                  shiftData <= '0';
                  
                  rowIndex <= row_counters(sprite_addr_row, sprite_addr_col);
                  upperLimit <= 255 - rowIndex*16;
                  lowerLimit <= 255 - rowIndex*16 - 15;
                  --povecamo counter v tabeli za naslednje branje
                  row_counters(sprite_addr_row, sprite_addr_col) <= 1 + row_counters(sprite_addr_row, sprite_addr_col);
                  dataChunk <= data(upperLimit downto lowerLimit);
            end if;
            
            if rising_edge(CLK100MHZ) then
                if presc = 0 then
                    --preberemo trenutni bit in glede na njegovo vrenost nastavimo topove
                    bitValue <= dataChunk(dataChunkCount);
                    bitVector <= (others => bitValue);
                    VGA_R <= bitVector;
                    VGA_G <= bitVector;
                    VGA_B <= bitVector;
                    dataChunkCount <= dataChunkCount + 1;
                    if dataChunkCount = 16 then
                        -- v naslednji iteraciji loudamo nov chunk
                        shiftData <= '1';
                    end if;
                elsif presc >= 3 then
                    -- VGA za izris enega pixla potrebuje 4 urine periode (40 nanos) 
                    presc <= 0;
                end if;
                presc <= presc + 1;
            end if;
        
        end if;
    end process;
    

end Behavioral;
