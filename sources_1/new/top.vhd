library IEEE;
use IEEE.STD_LOGIC_1164.all;

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
        CPU_RESETN : in STD_LOGIC;
        -- signali za VGA
        --SW         : in STD_LOGIC_VECTOR(0 downto 0);
        VGA_HS : out STD_LOGIC;
        VGA_VS : out STD_LOGIC;
        VGA_R  : out STD_LOGIC_VECTOR(3 downto 0);
        VGA_G  : out STD_LOGIC_VECTOR(3 downto 0);
        VGA_B  : out STD_LOGIC_VECTOR(3 downto 0)
    );
end entity;

architecture Behavioral of top is
    -- kaca_engine signali
    constant SIZE_X : integer := 40; -- 39 in spodaj brez minusov, da je povsod enako?
    constant SIZE_Y : integer := 30; -- 29??
    signal score : natural := 0;
    signal game_over : std_logic := '0';
    signal x_display : integer range 0 to SIZE_X - 1 := 0;
    signal y_display : integer range 0 to SIZE_Y - 1 := 0;
    signal sprite_ix : std_logic_vector(4 downto 0) := "00000";
    signal sprite_we : std_logic := '0';
    signal sprite_image_vector : std_logic_vector(0 to 255);
    
    --signali za display ram
    constant screen_width : integer := 640;
    constant screen_height : integer := 480;
    constant dispRam_width_bits : integer := 10;
    constant dispRam_height_bits : integer := 9;
    constant dispRam_word_size : integer := 1;
    
    signal topAddr_readY : integer range 0 to screen_height - 1 := 0;
    signal topAddr_readX : integer range 0 to screen_width - 1 := 0; --na za?etku prebere prvo vrstico
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

        index2sprite : entity work.index2sprite(Behavioral)
            port map(
                sprite_index => sprite_ix,
                sprite_image_bits => sprite_image_vector
            );
    
    
    -- ram katerega vsebina je enaka zaslonski sliki
    displayRam : entity work.framebuffer_RAM2(Behavioral)
            generic map(
                width => screen_width,
                height => screen_height
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
    
    vgaController: entity work.vgaController(Behavioral)
        generic map (
          dispRam_height_bits => dispRam_height_bits,
          dispRam_width_bits => dispRam_width_bits,
          dispRam_word_size => dispRam_word_size
          )
        port map (
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
             
end Behavioral;