library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity gyro is
      Port (
      CLK100MHZ : in std_logic;
      CPU_RESETN : in STD_LOGIC;
--      SW : in  std_logic_vector(15 downto 0); 
      LED : out  std_logic_vector(15 downto 0);
      
      ACL_SCLK           : out STD_LOGIC;
      ACL_MOSI       : out STD_LOGIC;
      ACL_MISO           : in STD_LOGIC;
      ACL_CSN           : out STD_LOGIC;
      -- PS2 interface signals
      ps2_clk        : inout std_logic;
      ps2_data       : inout std_logic;
      --7 seg value signal
      SevenSegVal    : out unsigned(31 downto 0);
      -- izhodni signali za smer
      levo    : out std_logic := '0'; 
      gor  : out std_logic := '0'; 
      desno   : out std_logic := '0'; 
      dol   : out std_logic := '0'
      );
      
      -- ADXL362 Accelerometer data signals
    signal ACCEL_X    : STD_LOGIC_VECTOR (8 downto 0);
    signal ACCEL_Y    : STD_LOGIC_VECTOR (8 downto 0);
    signal ACCEL_MAG  : STD_LOGIC_VECTOR (11 downto 0);
    signal ACCEL_TMP  : STD_LOGIC_VECTOR (11 downto 0);
     
    signal ACL_OFFSET : integer := 70;
    signal cpu_reset : std_logic := '0';
    
    signal accel_X_val : unsigned(31 downto 0);
    signal accel_Y_val : unsigned(31 downto 0);
    signal ax : unsigned(8 downto 0);
    signal ay : unsigned(8 downto 0);
end gyro;

architecture Behavioral of gyro is

component AccelerometerCtl is
generic 
(
   SYSCLK_FREQUENCY_HZ : integer := 100000;
   SCLK_FREQUENCY_HZ   : integer := 1000;
   NUM_READS_AVG       : integer := 16;
   UPDATE_FREQUENCY_HZ : integer := 1000
);
port
(
 SYSCLK     : in STD_LOGIC; -- System Clock
 RESET      : in STD_LOGIC; -- Reset button on the Nexys4 board is active low

 -- SPI interface Signals
 SCLK       : out STD_LOGIC;
 MOSI       : out STD_LOGIC;
 MISO       : in STD_LOGIC;
 SS         : out STD_LOGIC;
 
-- Accelerometer data signals
 ACCEL_X_OUT    : out STD_LOGIC_VECTOR (8 downto 0);
 ACCEL_Y_OUT    : out STD_LOGIC_VECTOR (8 downto 0);
 ACCEL_MAG_OUT  : out STD_LOGIC_VECTOR (11 downto 0);
 ACCEL_TMP_OUT  : out STD_LOGIC_VECTOR (11 downto 0)
);
end component;

begin 
   
   LED <= (others => '0');
   --SevenSegVal <= (others => '0');

    -- prikaz vrednosti gyrota na 7segDisp
   ax <= unsigned(ACCEL_X);
   accel_X_val <= resize(ax, 32);
   ay <= unsigned(ACCEL_Y);
   accel_Y_val <= resize(ay, 32);
--   SevenSegVal <= accel_X_val when SW(0) = '1' else accel_Y_val;
   
   --prikaz vrednosti gyrota na ledicah
--   LED <= resize(ACCEL_X, 16); --when SW(0) = '1' else resize(ACCEL_Y, 16);
--   LED <= "0000000" & ACCEL_X when SW(0) = '1' else "0000000" & ACCEL_Y;
   
   dol <= '0' when TO_INTEGER(unsigned(ACCEL_X)) < 255 + ACL_OFFSET else '1';
   gor <= '0' when TO_INTEGER(unsigned(ACCEL_X)) > 255 - ACL_OFFSET else '1';
   desno <= '0' when TO_INTEGER(unsigned(ACCEL_Y)) < 255 + ACL_OFFSET else '1';
   levo <= '0' when TO_INTEGER(unsigned(ACCEL_Y)) > 255 - ACL_OFFSET else '1';
   
Inst_AccelerometerCtl: AccelerometerCtl
   generic map
   (
        SYSCLK_FREQUENCY_HZ   => 100000000,
        SCLK_FREQUENCY_HZ     => 100000,
        NUM_READS_AVG         => 16,
        UPDATE_FREQUENCY_HZ   => 1000
   )
   port map
   (
       SYSCLK     => CLK100MHZ,
       RESET      => CPU_RESETN, 
       -- Spi interface Signals
       SCLK       => ACL_SCLK,
       MOSI       => ACL_MOSI,
       MISO       => ACL_MISO,
       SS         => ACL_CSN,
     
      -- Accelerometer data signals
       ACCEL_X_OUT   => ACCEL_X,
       ACCEL_Y_OUT   => ACCEL_Y,
       ACCEL_MAG_OUT => ACCEL_MAG,
       ACCEL_TMP_OUT => ACCEL_TMP
   );



end Behavioral;
