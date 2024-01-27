library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity kaca_premikalnik is
  port (
    clk : in std_logic;
    BTNU : in std_logic;
    BTND : in std_logic;
    BTNL : in std_logic;
    BTNR : in std_logic;
    smer_premika : out std_logic_vector(1 downto 0)
  );
end kaca_premikalnik;

architecture Behavioral of kaca_premikalnik is

  signal previous_smer_premika : std_logic_vector(1 downto 0) := "00";
  signal ismer_premika : std_logic_vector(1 downto 0) := "00";
  signal started : std_logic := '0';

  type istate is (ASSIGN_POS, CHECK_POS, WRITE_POS);
  signal state : istate := ASSIGN_POS;

begin

  nastavi_premik : process (clk)
  begin
    if rising_edge(clk) then
      case (state) is
        when ASSIGN_POS =>
          if BTNR = '1' then
            ismer_premika <= "00";
          elsif BTNU = '1' then
            ismer_premika <= "01";
          elsif BTNL = '1' then
            ismer_premika <= "10";
          elsif BTND = '1' then
            ismer_premika <= "11";
          end if;

          if started = '1' then
            state <= CHECK_POS;
          else
            state <= WRITE_POS;
          end if;
        when CHECK_POS =>
          -- do not allow 180 degree turns
          if (ismer_premika = "00" and previous_smer_premika = "10") or
            (ismer_premika = "10" and previous_smer_premika = "00") or
            (ismer_premika = "11" and previous_smer_premika = "01") or
            (ismer_premika = "01" and previous_smer_premika = "11") then
            ismer_premika <= previous_smer_premika;
          end if;
          state <= WRITE_POS;
        when WRITE_POS =>
          smer_premika <= ismer_premika;
          previous_smer_premika <= ismer_premika;
          started <= '1';
          state <= ASSIGN_POS;
      end case;
    end if;
  end process nastavi_premik;
end Behavioral;