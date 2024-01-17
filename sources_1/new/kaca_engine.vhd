library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity kaca_engine is
    generic (
        width : natural := 40;
        height : natural := 30);
    port (
        smer_premika : in std_logic_vector (2 downto 0);
        CLK100MHZ : in std_logic;
        allow_snake_move : in std_logic;
        score : out natural;
        x_display : out integer range 0 to width - 1;
        y_display : out integer range 0 to height - 1;
        sprite_ix : out std_logic_vector (4 downto 0);
        display_we : out std_logic;
        game_over : out std_logic);
end entity;

architecture Behavioral of kaca_engine is
    constant word_size : integer := 3;

    signal snake_startx : integer range 0 to width - 1 := width / 2;
    signal snake_starty : integer range 0 to height - 1 := height / 2;
    signal snake_endx : integer range 0 to width - 1 := width / 2;
    signal snake_endy : integer range 0 to height - 1 := height / 2;

    signal old_smer_premika : std_logic_vector (1 downto 0);

    signal newx : integer range -1 to width - 1;
    signal newy : integer range -1 to height - 1;

    signal iscore : natural := 0;
    signal has_sadje : std_logic := '0';

    signal addr_writeY : integer range 0 to height - 1;
    signal addr_writeX : integer range 0 to width - 1;
    signal addr_readY : integer range 0 to height - 1;
    signal addr_readX : integer range 0 to width - 1;
    signal data_write : std_logic_vector (word_size - 1 downto 0);
    signal data_read : std_logic_vector (word_size - 1 downto 0);
    signal RAM_we : std_logic := '0';

    type game_state is (
        CHECK_POS, DODAJ_SADEZ, POPRAVI_STARO_GLAVO, ZAPISI_NOVO_GLAVO, POPRAVI_STARI_REP, ZAPISI_NOVI_REP, END_GAME
    );

    signal state : game_state := CHECK_POS;

begin

    score <= iscore;

    -- Stanje igre
    ram : entity work.generic_RAM(Behavioral)
        generic map(
            width => width,
            height => height,
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

    -- Skrbi za premikanje kace
    premakni_kaco : process (CLK100MHZ, state, smer_premika)
    begin
        if rising_edge(CLK100MHZ) and allow_snake_move = '1' then
            case (state) is
                when END_GAME =>
                    display_we <= '0';
                    RAM_we <= '0';
                    game_over <= '1';
                when CHECK_POS =>
                    -- izracunaj novi koordinati glave kace
                    newx <= 0;
                    newy <= 0;
                    display_we <= '0';
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

                    -- preveri koordinate glave kace, ce bodo šle izven polja
                    if (newx =- 1 and snake_startx = 0) or (newx = 1 and snake_startx = width - 1) or (newy =- 1 and snake_starty = 0) or (newy = 1 and snake_starty = height - 1) then
                        state <= END_GAME;
                    elsif newx /= 0 or newy /= 0 then
                        -- izracunaj kooridnate glave kace
                        newx <= snake_startx + newx;
                        newy <= snake_starty + newy;

                        -- preveri pomnilniško lokacijo, ce tam obstaja
                        -- del kace

                        -- podaj naslov
                        addr_readX <= newx;
                        addr_readY <= newy;
                        -- podatki pridejo na data_read

                        -- data_read mora biti prazen ali jabolko, sicer je konec
                        if data_read /= "000" and data_read /= "001" then
                            state <= END_GAME;
                        else
                            -- ce je jabolko, povecaj rezultat
                            if data_read = "001" then
                                iscore <= iscore + 1;
                                has_sadje <= '0';
                            end if;
                        end if;
                    end if;

                    if has_sadje = '1' then
                        state <= POPRAVI_STARO_GLAVO;
                    else
                        state <= DODAJ_SADEZ;
                    end if;
                when DODAJ_SADEZ =>
                    -- poskusi dodati novo jabolko
                    -- kao random koordinate
                    addr_readX <= (iscore + snake_startx + snake_endy) mod width;
                    addr_readY <= (iscore + snake_starty + snake_endx) mod height;

                    if data_read = "000" then
                        -- dodaj jabolko
                        addr_writeX <= addr_readX;
                        addr_writeY <= addr_readY;
                        data_write <= "001";
                        RAM_we <= '1';
                        has_sadje <= '1';
                    end if;

                    state <= POPRAVI_STARO_GLAVO;
                when POPRAVI_STARO_GLAVO =>
                    -- popravi staro glavo
                    addr_writeX <= snake_startx;
                    addr_writeY <= snake_starty;
                    -- podatke damo na data_write
                    data_write <= smer_premika;
                    RAM_we <= '1';

                    -- todo tukajle se da lepse narediti (da je vsak ovinek drugačen, torej 8 ovinkov ne 4)
                    -- sporoci za zapis sprite-a
                    x_display <= snake_startx;
                    y_display <= snake_starty;

                    if old_smer_premika = smer_premika(1 downto 0) then
                        sprite_ix <= "100" & old_smer_premika; -- spremeni staro glavo v ravno telo
                    elsif (old_smer_premika = "00" and smer_premika(1 downto 0) = "01") or (old_smer_premika = "11" and smer_premika(1 downto 0) = "10") then
                        -- desno -> gor ali pa dol -> levo
                        sprite_ix <= "10101";
                    elsif (old_smer_premika = "01" and smer_premika(1 downto 0) = "00") or (old_smer_premika = "10" and smer_premika(1 downto 0) = "11") then
                        -- gor -> desno ali pa levo -> dol
                        sprite_ix <= "10111";
                    elsif (old_smer_premika = "00" and smer_premika(1 downto 0) = "11") or (old_smer_premika = "01" and smer_premika(1 downto 0) = "10") then
                        -- desno -> dol ali pa gor -> levo
                        sprite_ix <= "10110";
                    end if;

                    display_we <= '1';
                    state <= ZAPISI_NOVO_GLAVO;

                when ZAPISI_NOVO_GLAVO =>
                    -- zapiši novo glavo kace
                    snake_startx <= newx;
                    snake_starty <= newy;
                    addr_writeX <= snake_startx;
                    addr_writeY <= snake_starty;
                    data_write <= smer_premika;
                    RAM_we <= '1';

                    -- sporoci za zapis sprite-a
                    x_display <= snake_startx;
                    y_display <= snake_starty;
                    sprite_ix <= "001" & smer_premika(1 downto 0);
                    display_we <= '1';

                    state <= POPRAVI_STARI_REP;
                when POPRAVI_STARI_REP =>
                    -- odstrani rep kače in nastavi nov kazalec na rep
                    addr_readX <= snake_endx;
                    addr_readY <= snake_endy;

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
                    addr_writeX <= snake_endx;
                    addr_writeY <= snake_endy;
                    data_write <= "000"; -- pocisti stari rep
                    RAM_we <= '1';

                    -- sporoci za zapis sprite-a
                    x_display <= snake_startx;
                    y_display <= snake_starty;
                    sprite_ix <= "00000";
                    display_we <= '1';

                    -- nastavi nov rep
                    snake_endx <= snake_endx + newx;
                    snake_endy <= snake_endy + newy;

                    state <= ZAPISI_NOVI_REP;

                when ZAPISI_NOVI_REP =>
                    -- preberi smer novega repa (trupa)
                    addr_readX <= snake_endx;
                    addr_readY <= snake_endy;

                    -- javi spremembo repa (trup se spremeni v rep)
                    x_display <= snake_endx;
                    y_display <= snake_endy;
                    sprite_ix <= "010" & data_read(1 downto 0);

                    state <= CHECK_POS;
            end case;
        end if;
        old_smer_premika <= smer_premika(1 downto 0);
    end process;

end Behavioral;

-- ram data:
-- 1XY kača (00 - desno, 01 - gor, 10 - levo, 11 - dol)
-- 001 jabolko