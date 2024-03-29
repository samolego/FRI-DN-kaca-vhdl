library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity kaca_engine is
    generic (
        width : natural := 40;
        height : natural := 30);
    port (
        smer_premika : in std_logic_vector (1 downto 0);
        CLK100MHZ : in std_logic;
        allow_snake_move : in std_logic;
        done_reset : in std_logic;
        reset : in std_logic;
        score : out natural;
        x_display : out integer range 0 to width - 1;
        y_display : out integer range 0 to height - 1;
        sprite_ix : out std_logic_vector (4 downto 0);
        display_we : out std_logic;
        game_over : out std_logic
    );
end entity;

architecture Behavioral of kaca_engine is
    constant word_size : integer := 3;
    constant csnake_startx : integer := width / 2;
    constant csnake_endx : integer := csnake_startx;
    constant csnake_starty : integer := height / 2;
    constant csnake_endy : integer := csnake_starty;

    signal snake_startx : integer range 0 to width - 1 := csnake_startx;
    signal snake_starty : integer range 0 to height - 1 := csnake_starty;
    signal snake_endx : integer range 0 to width - 1 := csnake_endx;
    signal snake_endy : integer range 0 to height - 1 := csnake_endy;

    signal old_smer_premika : std_logic_vector (1 downto 0);
    signal ismer_premika : std_logic_vector (2 downto 0);

    signal newx : integer range -1 to width - 1;
    signal newy : integer range -1 to height - 1;

    signal iscore : natural := 0;
    signal igame_over : std_logic := '0';
    signal has_sadje : std_logic := '0';
    signal ate_sadez : std_logic := '0';

    signal addr_writeY : integer range 0 to height - 1;
    signal addr_writeX : integer range 0 to width - 1;
    signal addr_readY : integer range 0 to height - 1;
    signal addr_readX : integer range 0 to width - 1;
    signal data_write : std_logic_vector (word_size - 1 downto 0);
    signal data_read : std_logic_vector (word_size - 1 downto 0);
    signal RAM_we : std_logic := '0';

    type game_state is (
        CHECK_POS_0,
        CHECK_POS_1,
        CHECK_POS_2,
        CHECK_POS_3,
        CHECK_POS_4,
        DODAJ_SADEZ_0,
        DODAJ_SADEZ_1,
        POCAKAJ_ZAPIS_SADEZA,
        POPRAVI_STARO_GLAVO_0,
        POPRAVI_STARO_GLAVO_1,
        POCAKAJ_ZAPIS_STARE_GLAVE,
        ZAPISI_NOVO_GLAVO_0,
        POCAKAJ_ZAPIS_NOVE_GLAVE,
        POPRAVI_STARI_REP_0,
        POPRAVI_STARI_REP_1,
        POPRAVI_STARI_REP_2,
        POCAKAJ_ZAPIS_STAREGA_REPA,
        ZAPISI_NOVI_REP_0,
        ZAPISI_NOVI_REP_1,
        POCAKAJ_ZAPIS_NOVEGA_REPA,
        RESET_GAME,
        END_GAME
    );

    signal state : game_state := CHECK_POS_0;

    signal done_reset_gr : std_logic := '1';

begin

    score <= iscore;
    game_over <= igame_over;
    ismer_premika <= allow_snake_move & smer_premika;

    -- Stanje igre
    ram : entity work.generic_RAM(Behavioral)
        generic map(
            width => width,
            height => height,
            word_size => word_size
        )
        port map(
            clk => CLK100MHZ,
            reset => reset,
            done_reset => done_reset_gr,
            we => RAM_we,
            addr_writeY => addr_writeY,
            addr_writeX => addr_writeX,
            addr_readY => addr_readY,
            addr_readX => addr_readX,
            data_write => data_write,
            data_read => data_read
        );

    -- Skrbi za premikanje kace
    premakni_kaco : process (CLK100MHZ)
    begin
        if rising_edge(CLK100MHZ) then
            if reset = '1' then
                -- resetiraj vse
                iscore <= 0;
                igame_over <= '0';
                has_sadje <= '0';
                ate_sadez <= '0';
                snake_startx <= csnake_startx;
                snake_starty <= csnake_starty;
                snake_endx <= csnake_endx;
                snake_endy <= csnake_endy;

                -- clear RAM
                state <= RESET_GAME;
            else
                case (state) is
                    when RESET_GAME =>
                        -- clear RAM
                        -- wait for done_reset
                        if done_reset_gr = '1' and done_reset = '1' then
                            state <= CHECK_POS_0;
                        end if;
                    when END_GAME =>
                        igame_over <= '1';
                    when CHECK_POS_0 =>
                        display_we <= '0';
                        RAM_we <= '0';
                        -- izracunaj novi koordinati glave kace
                        case ismer_premika is
                            when "100" => -- desno
                                newy <= 0;
                                newx <= 1;
                            when "101" => -- gor
                                newy <= - 1;
                                newx <= 0;
                            when "110" => -- levo
                                newy <= 0;
                                newx <= - 1;
                            when "111" => -- dol
                                newy <= 1;
                                newx <= 0;
                            when others =>
                                newx <= 0;
                                newy <= 0;
                        end case;
                        state <= CHECK_POS_1;
                    when CHECK_POS_1 =>
                        if igame_over = '1' then
                            state <= END_GAME;
                        elsif (newx =- 1 and snake_startx = 0) or (newx = 1 and snake_startx = width - 1) or (newy =- 1 and snake_starty = 0) or (newy = 1 and snake_starty = height - 1) then
                            -- preveri koordinate glave kace, ce bodo šle izven polja
                            state <= END_GAME;
                        elsif newx /= 0 or newy /= 0 then
                            -- izracunaj koordinate glave kace
                            newx <= snake_startx + newx;
                            newy <= snake_starty + newy;

                            state <= CHECK_POS_2;
                        else
                            -- nismo se premaknili
                            state <= CHECK_POS_0;
                        end if;
                    when CHECK_POS_2 =>
                        -- preveri pomnilniško lokacijo, ce tam obstaja
                        -- del kace

                        -- podaj naslov
                        addr_readX <= newx;
                        addr_readY <= newy;

                        state <= CHECK_POS_3;
                    when CHECK_POS_3 =>
                        -- podatki pridejo na data_read

                        -- data_read mora biti prazen ali jabolko, sicer je konec
                        if data_read(2) = '1' then
                            -- zaleteli smo se v kaco
                            igame_over <= '1';
                            state <= CHECK_POS_4;
                        else
                            -- ce je jabolko, povecaj rezultat
                            if data_read = "001" then
                                iscore <= iscore + 1;
                                has_sadje <= '0';
                                ate_sadez <= '1';
                                state <= DODAJ_SADEZ_0;
                            else
                                -- je potrebno zaradi prvega sadeza
                                state <= CHECK_POS_4;
                            end if;
                        end if;
                    when CHECK_POS_4 =>
                        if has_sadje = '1' then
                            state <= POPRAVI_STARO_GLAVO_0;
                        else
                            state <= DODAJ_SADEZ_0;
                        end if;
                    when DODAJ_SADEZ_0 =>
                        -- poskusi dodati novo jabolko
                        -- kao random koordinate

                        -- prvo preberi ce je tam kaj
                        addr_readX <= (iscore + snake_startx + snake_endy) mod width;
                        addr_readY <= (iscore + snake_starty + snake_endx) mod height;
                        state <= DODAJ_SADEZ_1;
                    when DODAJ_SADEZ_1 =>
                        -- ce ni, dodaj jabolko
                        if data_read = "000" then
                            -- dodaj jabolko v game ram
                            addr_writeX <= addr_readX;
                            addr_writeY <= addr_readY;
                            data_write <= "001";
                            RAM_we <= '1';
                            -- doda jabolko na zaslon
                            x_display <= addr_readX;
                            y_display <= addr_readY;
                            sprite_ix <= "11111";
                            display_we <= '1';

                            has_sadje <= '1';
                            state <= POCAKAJ_ZAPIS_SADEZA;
                        else
                            state <= POPRAVI_STARO_GLAVO_0;
                        end if;
                    when POCAKAJ_ZAPIS_SADEZA =>
                        RAM_we <= '0';
                        display_we <= '0';
                        state <= POPRAVI_STARO_GLAVO_0;
                    when POPRAVI_STARO_GLAVO_0 =>
                        -- popravi staro glavo
                        addr_writeX <= snake_startx;
                        addr_writeY <= snake_starty;
                        -- podatke damo na data_write
                        data_write <= '1' & ismer_premika(1 downto 0);
                        RAM_we <= '1';
                        state <= POPRAVI_STARO_GLAVO_1;
                    when POPRAVI_STARO_GLAVO_1 =>
                        RAM_we <= '0';

                        -- todo tukajle se da lepse narediti (da je vsak ovinek drugačen, torej 8 ovinkov ne 4)
                        -- sporoci za zapis sprite-a
                        x_display <= snake_startx;
                        y_display <= snake_starty;

                        -- nastavimo sprite index
                        if old_smer_premika = ismer_premika(1 downto 0) then
                            sprite_ix <= "100" & old_smer_premika; -- spremeni staro glavo v ravno telo
                        elsif (old_smer_premika = "00" and ismer_premika(1 downto 0) = "01") or (old_smer_premika = "11" and ismer_premika(1 downto 0) = "10") then
                            -- desno -> gor ali pa dol -> levo
                            sprite_ix <= "01101";
                        elsif (old_smer_premika = "01" and ismer_premika(1 downto 0) = "00") or (old_smer_premika = "10" and ismer_premika(1 downto 0) = "11") then
                            -- gor -> desno ali pa levo -> dol
                            sprite_ix <= "01111";
                        elsif (old_smer_premika = "00" and ismer_premika(1 downto 0) = "11") or (old_smer_premika = "01" and ismer_premika(1 downto 0) = "10") then
                            -- desno -> dol ali pa gor -> levo
                            sprite_ix <= "01110";
                        else
                            -- levo -> gor ali pa dol -> desno
                            sprite_ix <= "01100";
                        end if;

                        display_we <= '1';
                        old_smer_premika <= ismer_premika(1 downto 0);

                        state <= POCAKAJ_ZAPIS_STARE_GLAVE;
                    when POCAKAJ_ZAPIS_STARE_GLAVE =>
                        display_we <= '0';
                        state <= ZAPISI_NOVO_GLAVO_0;
                    when ZAPISI_NOVO_GLAVO_0 =>
                        -- zapiši novo glavo kace
                        snake_startx <= newx;
                        snake_starty <= newy;
                        addr_writeX <= newx;
                        addr_writeY <= newy;
                        data_write <= '1' & ismer_premika(1 downto 0);
                        RAM_we <= '1';

                        -- sporoci za zapis sprite-a
                        x_display <= newx;
                        y_display <= newy;
                        sprite_ix <= "001" & ismer_premika(1 downto 0);
                        display_we <= '1';

                        state <= POCAKAJ_ZAPIS_NOVE_GLAVE;
                    when POCAKAJ_ZAPIS_NOVE_GLAVE =>
                        display_we <= '0';
                        RAM_we <= '0';

                        if ate_sadez = '1' then
                            -- ce si pojedel sadez, ne odstrani starega repa (podaljsaj kaco)
                            ate_sadez <= '0';
                            state <= CHECK_POS_0;
                        else
                            state <= POPRAVI_STARI_REP_0;
                        end if;
                    when POPRAVI_STARI_REP_0 =>
                        -- odstrani rep kače in nastavi nov kazalec na rep
                        addr_readX <= snake_endx;
                        addr_readY <= snake_endy;

                        state <= POPRAVI_STARI_REP_1;
                    when POPRAVI_STARI_REP_1 =>
                        -- podatki pridejo na data_read
                        case data_read(1 downto 0) is
                            when "00" => -- desno
                                newy <= 0;
                                newx <= 1;
                            when "01" => -- gor
                                newx <= 0;
                                newy <= - 1;
                            when "10" => -- levo
                                newy <= 0;
                                newx <= - 1;
                            when "11" => -- dol
                                newx <= 0;
                                newy <= 1;
                            when others =>
                                newx <= 0;
                                newy <= 0;
                        end case;
                        state <= POPRAVI_STARI_REP_2;
                    when POPRAVI_STARI_REP_2 =>
                        addr_writeX <= snake_endx;
                        addr_writeY <= snake_endy;
                        data_write <= "000"; -- pocisti stari rep
                        RAM_we <= '1';

                        -- sporoci za zapis sprite-a
                        x_display <= snake_endx;
                        y_display <= snake_endy;
                        sprite_ix <= "00000";
                        display_we <= '1';

                        state <= POCAKAJ_ZAPIS_STAREGA_REPA;
                    when POCAKAJ_ZAPIS_STAREGA_REPA =>
                        display_we <= '0';
                        RAM_we <= '0';

                        -- nastavi nov rep
                        snake_endx <= snake_endx + newx;
                        snake_endy <= snake_endy + newy;

                        state <= ZAPISI_NOVI_REP_0;
                    when ZAPISI_NOVI_REP_0 =>
                        -- preberi smer novega repa (trupa)
                        addr_readX <= snake_endx;
                        addr_readY <= snake_endy;

                        state <= ZAPISI_NOVI_REP_1;
                    when ZAPISI_NOVI_REP_1 =>
                        -- javi spremembo repa (trup se spremeni v rep)
                        x_display <= snake_endx;
                        y_display <= snake_endy;
                        if iscore = 0 then
                            sprite_ix <= "101" & data_read(1 downto 0);  -- kaca je dolga 1, zapisi mini sprite
                        else
                            sprite_ix <= "010" & data_read(1 downto 0);
                        end if;
                        display_we <= '1';

                        state <= POCAKAJ_ZAPIS_NOVEGA_REPA;
                    when POCAKAJ_ZAPIS_NOVEGA_REPA =>
                        display_we <= '0';
                        state <= CHECK_POS_0;
                end case;
            end if;
        end if;
    end process;

end Behavioral;

-- ram data:
-- 1XY kača (00 - desno, 01 - gor, 10 - levo, 11 - dol)
-- 001 jabolko