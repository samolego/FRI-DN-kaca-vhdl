----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/13/2023 01:22:38 PM
-- Design Name: 
-- Module Name: kaca_engine - Behavioral
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
use IEEE.STD_LOGIC_1164.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity kaca_engine is
    generic (
        width : natural := 40;
        height : natural := 30);
    port (
        smer_premika : in std_logic_vector (2 downto 0);
        CLK100MHZ : in std_logic;
        score : out natural;
        x_display : out integer range 0 to width - 1;
        y_display : out integer range 0 to height - 1;
        sprite_ix : out std_logic_vector (2 downto 0);
        we : out std_logic;
        game_over : out std_logic);
end entity;

architecture Behavioral of kaca_engine is
    -- todo: samodejno izračunaj števila bitov iz višine in širine
    constant width_bits : integer := 6;
    constant height_bits : integer := 5;
    constant word_size : integer := 3;

    signal snake_startx : integer range 0 to width - 1;
    signal snake_starty : integer range 0 to height - 1;
    signal snake_endx : integer range 0 to width - 1;
    signal snake_endy : integer range 0 to height - 1;

    signal newx : integer range -1 to width - 1;
    signal newy : integer range -1 to height - 1;

    signal end_game : std_logic := '0';
    signal iscore : natural := 0;

    signal addr_writeY : std_logic_vector (height_bits - 1 downto 0);
    signal addr_writeX : std_logic_vector (width_bits - 1 downto 0);
    signal addr_readY : std_logic_vector (height_bits - 1 downto 0);
    signal addr_readX : std_logic_vector (width_bits - 1 downto 0);
    signal data_write : std_logic_vector (word_size - 1 downto 0);
    signal data_read : std_logic_vector (word_size - 1 downto 0);
    signal RAM_we : std_logic := '0';

begin
    -- Stanje igre
    game_state : entity work.generic_RAM(Behavioral)
        generic map(
            width => width,
            height => height,
            height_bits => height_bits,
            width_bits => width_bits,
            word_size => word_size
        )
        port map(
            clk => CLK100MHZ,
            we => RAM_we,
            addr_writeY => addr_writeY,
            addr_writeX => addr_writeX,
            addr_readY => addr_readY,
            addr_readX => addr_readX,
            data_write => data_write,
            data_read => data_read
        );
    -- Skrbi za premikanje kače
    premakni_kaco : process (CLK100MHZ)
    begin
        if rising_edge(CLK100MHZ) and end_game = '0' then

            -- izracunaj novi koordinati glave kače
            newx <= 0;
            newy <= 0;
            RAM_we <= '0';
            case smer_premika is
                when "100" => -- desno
                    newx <= 1;
                when "101" => -- gor
                    newy <= - 1;
                when "110" => -- levo
                    newx <= - 1;
                when "111" => -- dol
                    newy <= 1;
                when others =>
                    newx <= 0;
                    newy <= 0;
            end case;

            -- preveri koordinate glave kače, če bodo šle izven polja
            if (newx =- 1 and snake_startx = 0) or (newx = 1 and snake_startx = width - 1) or (newy =- 1 and snake_starty = 0) or (newy = 1 and snake_starty = height - 1) then
                end_game <= '1';
            elsif newx /= 0 or newy /= 0 then
                -- izracunaj kooridnate glave kače
                newx <= snake_startx + newx;
                newy <= snake_starty + newy;

                -- preveri pomnilniško lokacijo, če tam obstaja
                -- del kače

                -- podaj naslov
                addr_readX <= std_logic_vector(newx);
                addr_readY <= std_logic_vector(newy);
                -- podatki pridejo na data_read

                -- data_read mora biti prazen ali jabolko, sicer je konec
                if data_read /= "000" and data_read /= "001" then
                    end_game <= '1';
                else
                    -- če je jabolko, povečaj rezultat
                    if data_read = "001" then
                        iscore <= iscore + 1;
                    end if;

                    -- popravi staro glavo
                    addr_writeX <= std_logic_vector(snake_startx);
                    addr_writeY <= std_logic_vector(snake_starty);
                    -- podatke damo na data_write
                    data_write <= smer_premika;
                    RAM_we <= '1';

                    -- todo : kako počakati, da zapiše?
                    -- todo : javi spremembo na output

                    -- zapiši novo glavo kače
                    snake_startx <= newx;
                    snake_starty <= newy;
                    data_write <= smer_premika;
                    RAM_we <= '1';

                    -- todo : kako počakati, da zapiše?
                    -- todo : javi spremembo na output
                    -- odstrani rep kače in nastavi nov kazalec na rep
                    addr_readX <= std_logic_vector(snake_endx);
                    addr_readY <= std_logic_vector(snake_endy);

                    -- podatki pridejo na data_read
                    case data_read is
                        when "100" => -- desno
                            newx <= 1;
                        when "101" => -- gor
                            newy <= - 1;
                        when "110" => -- levo
                            newx <= - 1;
                        when "111" => -- dol
                            newy <= 1;
                        when others =>
                            newx <= 0;
                            newy <= 0;
                    end case;
                    addr_writeX <= std_logic_vector(snake_endx);
                    addr_writeY <= std_logic_vector(snake_endy);
                    data_write <= "000"; -- počisti stari rep
                    RAM_we <= '1';

                    -- počakaj da zapiše
                    -- todo : javi spremembo na output

                    -- nastavi nov rep
                    snake_endx <= snake_endx + newx;
                    snake_endy <= snake_endy + newy;

                end if;

            end if;
        end if;
    end process;

    score <= iscore;
    game_over <= end_game;

end Behavioral;

-- ram data:
-- 1XY kača (00 - desno, 01 - gor, 10 - levo, 11 - dol)
-- 001 jabolko