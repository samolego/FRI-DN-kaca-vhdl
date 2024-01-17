library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;
--tkrotk

entity top is
    port (
        CLK100MHZ : in std_logic;
        CPU_RESETN : in std_logic;
        -- signali za VGA
        --SW         : in STD_LOGIC_VECTOR(0 downto 0);
        VGA_HS : out std_logic;
        VGA_VS : out std_logic;
        VGA_R : out std_logic_vector(3 downto 0);
        VGA_G : out std_logic_vector(3 downto 0);
        VGA_B : out std_logic_vector(3 downto 0);
        -- signali za 7 segmentni zaslon
        BTNC : in std_logic;
        SEG : out unsigned(6 downto 0);
        AN : out unsigned(7 downto 0)
    );
end entity;

architecture Behavioral of top is
    -- kaca_engine signali
    -- stevilo ploscic na zaslonu (spritov do dolzini in visini)
    constant SIZE_X : integer := 40;
    constant SIZE_Y : integer := 30;
    -- trenutni rezultat (tale je zgolj out signal, pravi score je v kaca_engine)
    signal score : natural := 0;
    signal game_over : std_logic := '0';
    -- kam naj se zapise sprite na zaslon
    signal x_display : integer range 0 to SIZE_X - 1 := 0;
    signal y_display : integer range 0 to SIZE_Y - 1 := 0;
    -- index sprita, ki naj se zapise (glej index2sprite.vhd)
    signal sprite_ix : std_logic_vector(4 downto 0) := "00000";
    -- ali dovoli zapis sprita
    signal sprite_we : std_logic := '0';

    --signali za display ram
    constant screen_width : integer := 640;
    constant screen_height : integer := 480;
    constant dispRam_width_bits : integer := 10;
    constant dispRam_height_bits : integer := 9;
    constant dispRam_word_size : integer := 1;

    signal topAddr_readY : integer range 0 to screen_height - 1 := 0;
    signal topAddr_readX : integer range 0 to screen_width - 1 := 0; --na zacetku prebere prvo vrstico
    signal top_data_read : std_logic := '0';

begin

    kaca_engine : entity work.kaca_engine(Behavioral)
        generic map(
            width => SIZE_X,
            height => SIZE_Y
        )
        port map(
            smer_premika => "100",
            CLK100MHZ => CLK100MHZ,
            score => score,
            game_over => game_over,
            x_display => x_display,
            y_display => y_display,
            sprite_ix => sprite_ix,
            display_we => sprite_we
        );

    -- ram katerega vsebina je enaka zaslonski sliki
    displayRam : entity work.framebuffer_RAM2(Behavioral)
        generic map(
            width => SIZE_X,
            height => SIZE_Y
        )
        port map(
            clk => CLK100MHZ,
            we => sprite_we,
            addr_writeY => x_display,
            addr_writeX => y_display,
            addr_readY => topAddr_readY,
            addr_readX => topAddr_readX,
            sprite_idx2write => sprite_ix,
            data_read => top_data_read
        );

    vgaController : entity work.vgaController(Behavioral)
        generic map(
            dispRam_height_bits => dispRam_height_bits,
            dispRam_width_bits => dispRam_width_bits,
            dispRam_word_size => dispRam_word_size
        )
        port map(
            CLK100MHZ => CLK100MHZ,
            CPU_RESETN => CPU_RESETN,
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
            reset => BTNC,
            value => to_unsigned(integer(score), 32)
        );

end Behavioral;