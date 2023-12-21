----------------------------------------------------------------------------------
-- Krmilnik za VGA - glavni modul
-- verzija: 2023-11-15
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity vgaController is
    Port ( CLK100MHZ : in STD_LOGIC;
           CPU_RESETN : in STD_LOGIC;
           SW         : in STD_LOGIC_VECTOR(0 downto 0);
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
    
    process (SW, display_area, row, column)
    begin
        if SW = "0" then
            -- bel zaslon
            if display_area='1' then    
                VGA_R <= "1111";
                VGA_G <= "1111";
                VGA_B <= "1111";
            else
                VGA_R <= "0000";
                VGA_G <= "0000";
                VGA_B <= "0000";
            end if;
        else
            -- bel rob            
            if display_area='1' and (row=0 or row=479 or column=0 or column=639) then    
                VGA_R <= "1111";
                VGA_G <= "1111";
                VGA_B <= "1111";
            else
                VGA_R <= "0000";
                VGA_G <= "0000";
                VGA_B <= "0000";
            end if;
        end if;
    end process;
    

end Behavioral;
