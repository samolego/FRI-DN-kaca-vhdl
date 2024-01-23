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

begin

  nastavi_premik : process (clk)
  begin
    if rising_edge(clk) then
      if BTNR = '1' then
        smer_premika <= "00";
      elsif BTNU = '1' then
        smer_premika <= "01";
      elsif BTNL = '1' then
        smer_premika <= "10";
      elsif BTND = '1' then
        smer_premika <= "11";
      end if;
    end if;
  end process nastavi_premik;
end Behavioral;