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
        CLK100MHZ : in std_logic
    );
end entity;

architecture Behavioral of top is
    constant SIZE_X : integer := 40;
    constant SIZE_Y : integer := 30;

    signal score : natural := 0;
    signal game_over : std_logic := '0';

    signal x_display : integer range 0 to SIZE_X - 1 := 0;
    signal y_display : integer range 0 to SIZE_Y - 1 := 0;
    signal sprite_ix : std_logic_vector(2 downto 0) := "000";
    signal sprite_we : std_logic := '0';
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
            we => sprite_we
        );

end Behavioral;