----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/11/2024 11:34:04 PM
-- Design Name: 
-- Module Name: testGyro - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity testGyro is
      Port (
      CLK100MHZ : in std_logic;
      CPU_RESETN : in STD_LOGIC;
      SW : out  std_logic_vector(15 downto 0); --POPRAVI NA IN!!
      LED : out  std_logic_vector(15 downto 0);
      
      ACL_SCLK           : out STD_LOGIC;
      ACL_MOSI       : out STD_LOGIC;
      ACL_MISO           : in STD_LOGIC;
      ACL_CSN           : out STD_LOGIC;
      -- PS2 interface signals
      ps2_clk        : inout std_logic;
      ps2_data       : inout std_logic);
      
      -- ADXL362 Accelerometer data signals
    signal ACCEL_X    : STD_LOGIC_VECTOR (8 downto 0);
    signal ACCEL_Y    : STD_LOGIC_VECTOR (8 downto 0);
    signal ACCEL_MAG  : STD_LOGIC_VECTOR (11 downto 0);
    signal ACCEL_TMP  : STD_LOGIC_VECTOR (11 downto 0);
    
    signal levo  : std_logic := '0'; 
    signal naprej   : std_logic := '0'; 
    signal desno : std_logic := '0'; 
    signal nazaj   : std_logic := '0'; 
    signal ACL_OFFSET : integer := 60;
    signal cpu_reset : std_logic := '0';
end testGyro;

architecture Behavioral of testGyro is

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
   SW <= (others => '0');
   --LED <= (others => '0');
   --LED <= (0=>desno, 1=>naprej, 2=>levo, 3=>nazaj, others =>'0');
   LED(15 downto 8) <= ACCEL_X(8 downto 1);
   LED(7 downto 0) <= ACCEL_Y(8 downto 1);
   
   naprej <= '1' when TO_INTEGER(unsigned(ACCEL_X)) < 255 + ACL_OFFSET else '0';
   nazaj <= '1' when TO_INTEGER(unsigned(ACCEL_X)) > 255 - ACL_OFFSET else '0';
   desno <= '1' when TO_INTEGER(unsigned(ACCEL_Y)) < 255 + ACL_OFFSET else '0';
   levo <= '1' when TO_INTEGER(unsigned(ACCEL_Y)) > 255 + ACL_OFFSET else '0';
   
   cpu_reset <= not CPU_RESETN;
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
       RESET      => cpu_reset, 
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
