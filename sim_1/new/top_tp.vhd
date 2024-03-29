----------------------------------------------------------------------------------
-- TEST BENCH ZA SIMULACIJO
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.all;

entity top_tp is
--  Port ( );
end top_tp;

architecture Behavioral of top_tp is
    constant clock_period: time := 10 ns;
    signal clock:         std_logic := '0';
    signal cpuR : std_logic := '1';
    signal VGA_HS : STD_LOGIC;
    signal VGA_VS : STD_LOGIC;
    signal VGA_R  : STD_LOGIC_VECTOR(3 downto 0);
    signal VGA_G  : STD_LOGIC_VECTOR(3 downto 0);
    signal VGA_B  : STD_LOGIC_VECTOR(3 downto 0);
    
    signal topAddr_readY : std_logic_vector (9 - 1 downto 0):= (others => '0');
    signal topAddr_readX : std_logic_vector (10 - 1 downto 0) := (others => '0'); --na za?etku prebere prvo vrstico
    --signal data_read : std_logic_vector (1 - 1 downto 0);
    signal button : std_logic := '0';
    
    signal SEG : unsigned(6 downto 0);
    signal AN : unsigned(7 downto 0);
        -- signali z gyro
    signal ACL_SCLK : STD_LOGIC;
    signal    ACL_MOSI       :  STD_LOGIC;
     signal   ACL_MISO       : STD_LOGIC;
     signal   ACL_CSN        :  STD_LOGIC;
        -- generalni signali
     signal   SW :   std_logic_vector(15 downto 0); 
      signal  LED :  std_logic_vector(15 downto 0);
    
begin
     uut: entity work.top(Behavioral)
    port map(
        CLK100MHZ => clock,
        BTNU => '0',
        BTND => '0',
        BTNL => button,
        BTNR => not button,
        BTNC => '0',
        CPU_RESETN => cpuR,
        -- signali za VGA
        VGA_HS => VGA_HS,
        VGA_VS => VGA_VS,
        VGA_R => VGA_R,
        VGA_G => VGA_G,
        VGA_B => VGA_B,
        SIM => '1', --ODKOMENTIRAJ SIM  v TOP!
        SEG => SEG,
        AN => AN,
        -- signali z gyro
        ACL_SCLK => ACL_SCLK,
        ACL_MOSI => ACL_MOSI, 
        ACL_MISO => ACL_MISO,
        ACL_CSN  => ACL_CSN,
        -- generalni signali
        SW => SW, 
        LED => LED
       );
       
     --simuliraj uro
    clk: process
    begin
        wait for clock_period/2;
        clock <= not clock;
    end process;
    
    --testni program za ram
    testprog: process
    begin
--    wait for 2*clock_period;
--    topAddr_readY <= (0|1 => '1', others => '0');
--    topAddr_readX <= (0|1 => '1', others => '0');
    
--    wait for 4*clock_period;
--    topAddr_readY <= (0|1 => '1', others => '0');
--    topAddr_readX <= (0|1|2 => '1', others => '0');
    --wait for 5*clock_period;
    
    --wait for  2*clock_period;
    
    wait for 10*clock_period;
    button <= '1';
    wait for 2*clock_period;
    
    wait; -- wait forever
    end process;
    

end Behavioral;
