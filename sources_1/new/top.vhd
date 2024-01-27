library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity top is
    port (
        CLK100MHZ : in std_logic;
        CPU_RESETN : in std_logic;
        BTNU : in std_logic;
        BTND : in std_logic;
        BTNL : in std_logic;
        BTNR : in std_logic;
        BTNC : in std_logic;
        -- signali za VGA     
        VGA_HS : out std_logic;
        VGA_VS : out std_logic;
        VGA_R : out std_logic_vector(3 downto 0);
        VGA_G : out std_logic_vector(3 downto 0);
        VGA_B : out std_logic_vector(3 downto 0);
        -- signali za 7 segmentni zaslon
        SEG : out unsigned(6 downto 0);
        AN : out unsigned(7 downto 0);
        -- signali z gyro
        ACL_SCLK       : out STD_LOGIC;
        ACL_MOSI       : out STD_LOGIC;
        ACL_MISO       : in STD_LOGIC;
        ACL_CSN        : out STD_LOGIC;
        -- generalni signali
        SW : in  std_logic_vector(15 downto 0); 
        LED : out  std_logic_vector(15 downto 0) --:= (others => '0');
        -- ce je simulacija aktivna
        --SIM : in std_logic
    );
end entity;

architecture Behavioral of top is
    
    -- kaca_engine signali
    -- stevilo ploscic na zaslonu (spritov do dolzini in visini)
    constant SIZE_X : integer := 40;
    constant SIZE_Y : integer := 30;
    -- ko je 1, se kaca lahko premakne
    signal allow_snake_move : std_logic := '0';
    -- smer premikanja kace (00 - desno, 01 - gor, 10 - levo, 11 - dol)
    -- vezan na giroskop (oz. gumbe)
    signal smer_premika : std_logic_vector(1 downto 0) := "00";
    -- na koliko urinih period se kaca premakne
    constant SNAKE_MOVE_TIME : integer := 50_000_000;
    -- trenutni rezultat (tale je zgolj out signal, pravi score je v kaca_engine)
    signal score : natural := 0;
    -- signal ko je konec igre
    signal game_over : std_logic := '0';
    -- kam naj se zapise sprite na zaslon
    signal x_display : integer range 0 to SIZE_X - 1 := 0;
    signal y_display : integer range 0 to SIZE_Y - 1 := 0;
    -- index sprita, ki naj se zapise (glej index2sprite.vhd)
    signal sprite_ix : std_logic_vector(4 downto 0) := "00000";
    -- ali dovoli zapis sprita
    signal display_we : std_logic := '0';

    --signali za display ram
    constant screen_width : integer := 640;
    constant screen_height : integer := 480;
    constant dispRam_width_bits : integer := 10;
    constant dispRam_height_bits : integer := 9;
    constant dispRam_word_size : integer := 1;

    signal topAddr_readY : integer range 0 to screen_height - 1 := 0;
    signal topAddr_readX : integer range 0 to screen_width - 1 := 0; --na zacetku prebere prvo vrstico
    signal top_data_read : std_logic; -- := '0';

    --ledice in registri
    signal LED_reg : std_logic_vector(15 downto 0);
    
    --signali za gyro
    signal GyroValBuffer : unsigned(31 downto 0);
    signal levo  : std_logic := '0'; 
    signal gor   : std_logic := '0'; 
    signal desno : std_logic := '0'; 
    signal dol   : std_logic := '0';
    
     --signali za sitni in neumni vivado
    signal CPU_RESET : std_logic;
    signal snakeMoveOrSim : std_logic;
    signal smerLevo : std_logic;
    signal smerDesno : std_logic;
    signal smerGor : std_logic;
    signal smerDol : std_logic;
    signal ceOneSec: std_logic;
    
begin
    -- trenutno bo reset z klikom na BTNC
    CPU_RESET <= BTNC; --not CPU_RESETN;
    
    snakeMoveOrSim <= allow_snake_move;-- or SIM;
    
    -- motor igre
    kaca_engine : entity work.kaca_engine(Behavioral)
        generic map(
            width => SIZE_X,
            height => SIZE_Y
        )
        port map(
            smer_premika => smer_premika,
            CLK100MHZ => CLK100MHZ,
            allow_snake_move => snakeMoveOrSim,
            score => score,
            game_over => game_over,
            x_display => x_display,
            y_display => y_display,
            sprite_ix => sprite_ix,
            display_we => display_we
        );

    -- modul, ki nastavi, kdaj se kaca lahko premakne
    snake_move_prescaler : entity work.prescaler(Behavioral)
        generic map(limit => SNAKE_MOVE_TIME)
        port map(
            --mogoce na switch fast and slow premikanje ka?e?
            clock => CLK100MHZ,
            reset => CPU_RESET, --not CPU_RESETN,
            clock_enable => allow_snake_move
        );

    -- modul, ki nastavlja smer premikanja kace
    smerGor <= BTNU or gor;
    smerDol <= BTND or dol;
    smerDesno <= BTNR or desno;
    smerLevo <= BTNL or levo;
    kaca_premikalnik : entity work.kaca_premikalnik(Behavioral)
        port map(
            clk => CLK100MHZ,
            BTNU => smerGor,
            BTND => smerDol,
            BTNL => smerLevo,
            BTNR => smerDesno,
            smer_premika => smer_premika
        );

    -- ram katerega vsebina je enaka zaslonski sliki
    displayRam : entity work.framebuffer_RAM2(Behavioral)
        generic map(
            width => SIZE_X,
            height => SIZE_Y,
            screen_width => screen_width,
            screen_height => screen_height
        )
        port map(
            clk => CLK100MHZ,
            display_we => display_we,
            addr_writeY => y_display,
            addr_writeX => x_display,
            addr_readY => topAddr_readY,
            addr_readX => topAddr_readX,
            sprite_idx2write => sprite_ix,
            display_bit_read => top_data_read
        );

    vgaController : entity work.vgaController(Behavioral)
        generic map(
            dispRam_height_bits => dispRam_height_bits,
            dispRam_width_bits => dispRam_width_bits,
            dispRam_word_size => dispRam_word_size
        )
        port map(
            CLK100MHZ => CLK100MHZ,
            CPU_RESET => CPU_RESET,
            VGA_HS => VGA_HS,
            VGA_VS => VGA_VS,
            VGA_R => VGA_R,
            VGA_G => VGA_G,
            VGA_B => VGA_B,
            ram_addr_readY => topAddr_readY,
            ram_addr_readX => topAddr_readX,
            data_read => top_data_read
        );

    -- stevilo tock na 7 segmentnem zaslonu
    scoreDisplay : entity work.seven_seg_display(Behavioral)
        port map(
            anode => AN,
            cathode => SEG,
            clock => CLK100MHZ,
            reset => CPU_RESET, --not CPU_RESETN,
            value => to_unsigned(integer(score), 32), --GyroValBuffer --TUKAJ MI JAVLJA NAPAKO PA POJMA NIMAM ZAKVA
            game_over => game_over
        );
    
    Gyro: entity work.gyro(Behavioral)
      port map (
      CLK100MHZ => CLK100MHZ,
      CPU_RESETN => CPU_RESET, --not CPU_RESETN,
      SW => SW,
      LED => LED_reg,
      
      ACL_SCLK => ACL_SCLK,
      ACL_MOSI => ACL_MOSI,
      ACL_MISO => ACL_MISO,
      ACL_CSN => ACL_CSN,
      -- PS2 interface signals ne uporbljamo
      SevenSegVal => GyroValBuffer,
      levo => levo,
      desno => desno,
      gor => gor,
      dol => dol
      );
      
      --ledice za prikaz signalov
      LED <= (4=>desno, 0=>gor, 5=>levo, 1=>dol, 13|12|11|10|9=>game_over, others =>'0');
end Behavioral;