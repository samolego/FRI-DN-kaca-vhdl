----------------------------------------------------------------------------------
-- Krmilnik za VGA, ki bere vrstico po vrstico iz disaplyRama
-- verzija: 2023-11-15

--! MEJE ZA COUNT SO HARDKODIRANE, ZATO N SPREMINJAJ VELIKOSTI EKRANA!
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.all;  

entity vgaController is
    generic (
          dispRam_height_bits : integer;
          dispRam_width_bits : integer;
          dispRam_word_size : integer
          );
    Port ( CLK100MHZ : in STD_LOGIC;
           CPU_RESETN : in STD_LOGIC;
           --data       : in STD_LOGIC_VECTOR(255 downto 0);
           VGA_HS : out STD_LOGIC;
           VGA_VS : out STD_LOGIC;
           VGA_R  : out STD_LOGIC_VECTOR(3 downto 0);
           VGA_G  : out STD_LOGIC_VECTOR(3 downto 0);
           VGA_B  : out STD_LOGIC_VECTOR(3 downto 0);
           --dodajanje rama
           ram_addr_readY : inout std_logic_vector (dispRam_height_bits - 1 downto 0);
           ram_addr_readX : inout std_logic_vector (dispRam_width_bits - 1 downto 0);
           data_read : in std_logic_vector (dispRam_word_size - 1 downto 0)
           );
end vgaController;

architecture Behavioral of vgaController is

signal CE : std_logic;
signal rst : std_logic;
signal display_area_h : std_logic;
signal display_area_v : std_logic;
signal display_area   : std_logic;
signal vga_column : natural range 0 to 639;
signal vga_row    : natural range 0 to 479;

--tabela, ki steje katero vrstico sprita na data bomo izrisali
--type twoDimArray is array (natural range <>, natural range <>) of natural range 0 to 15;
--signal row_counters : twoDimArray(0 to 39, 0 to 29);
--signal sprite_addr_row : natural range 0 to 29;
--signal sprite_addr_col : natural range 0 to 39;
--signal upperLimit : natural range 255 to 0;
--signal lowerLimit : natural range 255 to 0;

--signal rowIndex : natural range 0 to dispRam_width_bits;
--signal rowToDisplay: std_logic_vector(15 downto 0);
--signal getNewData: std_logic := '1';
--signal presc : natural range 0 to 4 := 0;
--signal bitInRowCount : natural range 0 to 15;
signal bitValue: std_logic_vector(dispRam_word_size - 1 downto 0);
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
        column => vga_column,
        hsync => VGA_HS
    );
    
    vsync: entity work.vsync
    port map(
        clock => CLK100MHZ, 
        reset => rst,
        clock_enable => CE,
        display_area => display_area_v,
        row => vga_row, 
        vsync => VGA_VS
    );
    
    -- Logika za prizig elektronskih topov (signali RGB)
    display_area <= display_area_h AND display_area_v;
    
    --signali za branje iz rama
    ram_addr_readY <= std_logic_vector(to_unsigned(vga_row, ram_addr_readY'length));
    ram_addr_readX <= std_logic_vector(to_unsigned(vga_column, ram_addr_readX'length));
    
    process (display_area, ram_addr_readX)
    begin
         if display_area='1' then
                bitValue <= data_read;
                bitVector <= (others => bitValue(0));
                VGA_R <= bitVector;
                VGA_G <= bitVector;
                VGA_B <= bitVector;
          end if;
    end process;
--            -- v rowToDisplay zapišemo novo vrstico
--            if getNewData = '1' then
--                  getNewData <= '0';
                  
--                  --trenutna vrednost podaktov v ramu na vrstici counterja
--                  rowToDisplay <= data_read;
--                  --pove?aj counter, ram bo ta?as že posodobil signal data_read, ki ga bomo ob naslednjem vhodu v zanko prepisali
--                  ram_addr_readX <= std_logic_vector(unsigned(ram_addr_readX) + 1);
                  
----                  rowIndex <= row_counters(sprite_addr_row, sprite_addr_col);
----                  upperLimit <= 255 - rowIndex*16;
----                  lowerLimit <= 255 - rowIndex*16 - 15;
----                  --povecamo counter v tabeli za naslednje branje
----                  row_counters(sprite_addr_row, sprite_addr_col) <= 1 + row_counters(sprite_addr_row, sprite_addr_col);
----                  dataChunk <= data(upperLimit downto lowerLimit);
--            end if;
                    
            -- VGA za izris enega pixla potrebuje 4 urine periode (40 nano s), zato imamo stevec presc(ailer) ki gre od 0 do 3  
         
--            if rising_edge(CLK100MHZ) then
--                if presc = 0 then
--                    --preberemo trenutni bit in glede na njegovo vrenost nastavimo topove
--                    bitValue <= data_read;
--                    bitVector <= (others => bitValue(0));
--                    VGA_R <= bitVector;
--                    VGA_G <= bitVector;
--                    VGA_B <= bitVector;
----                    bitInRowCount <= bitInRowCount + 1;
----                    if bitInRowCount >= 256 then
----                        -- v naslednji iteraciji loudamo novo vrstico
----                        getNewData <= '1';
----                        bitInRowCount <= 0;
----                    end if;
--                    presc <= presc + 1;  
--                elsif presc >= 3 then
--                    presc <= 0;
--                else 
--                presc <= presc + 1;  
--                end if;
--            end if;
        
--        end if;
--    end process;
    
    
    
--    VGA ROW BY ROW 
--    process (data, display_area, ram_addr_readX)
--    begin
--            -- OPOMBA bitInRowCount je podoben kot column
--            --        ram_addr_readX je podobne kot row
--            --nsignala sta ustvarjena na novo, zato da bo pri upscejlanju manj dela in da se umes ne resetirata na 0 kot se signala row in colum
--            -- OPOMBA 2 za delovanje tega programa je potrebno implementirati read_data_row v generic Ram modulu
--         if display_area='1' then
--            -- v rowToDisplay zapišemo novo vrstico
--            if getNewData = '1' then
--                  getNewData <= '0';
                  
--                  --trenutna vrednost podaktov v ramu na vrstici counterja
--                  rowToDisplay <= data_read;
--                  --pove?aj counter, ram bo ta?as že posodobil signal data_read, ki ga bomo ob naslednjem vhodu v zanko prepisali
--                  ram_addr_readX <= std_logic_vector(unsigned(ram_addr_readX) + 1);
                  
----                  rowIndex <= row_counters(sprite_addr_row, sprite_addr_col);
----                  upperLimit <= 255 - rowIndex*16;
----                  lowerLimit <= 255 - rowIndex*16 - 15;
----                  --povecamo counter v tabeli za naslednje branje
----                  row_counters(sprite_addr_row, sprite_addr_col) <= 1 + row_counters(sprite_addr_row, sprite_addr_col);
----                  dataChunk <= data(upperLimit downto lowerLimit);
--            end if;
                    
--            -- VGA za izris enega pixla potrebuje 4 urine periode (40 nano s), zato imamo stevec presc(ailer) ki gre od 0 do 3  
         
--            if rising_edge(CLK100MHZ) then
--                if presc = 0 then
--                    --preberemo trenutni bit in glede na njegovo vrenost nastavimo topove
--                    bitValue <= rowToDisplay(bitInRowCount);
--                    bitVector <= (others => bitValue);
--                    VGA_R <= bitVector;
--                    VGA_G <= bitVector;
--                    VGA_B <= bitVector;
--                    bitInRowCount <= bitInRowCount + 1;
--                    if bitInRowCount >= 256 then
--                        -- v naslednji iteraciji loudamo novo vrstico
--                        getNewData <= '1';
--                        bitInRowCount <= 0;
--                    end if;
--                    presc <= presc + 1;  
--                elsif presc >= 3 then
--                    presc <= 0;
--                else 
--                presc <= presc + 1;  
--                end if;
--            end if;
        
--        end if;
--    end process;
    

end Behavioral;
