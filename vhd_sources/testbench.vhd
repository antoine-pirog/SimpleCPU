library ieee;
use ieee.std_logic_1164.all;

entity testbench is
end testbench;

architecture behavioral of testbench is
    signal CPU_RESET_n : std_logic := '1';
    signal SW   : std_logic_vector(9 downto 0) := (others => '0');
    signal KEY  : std_logic_vector(3 downto 0) := (others => '1');
    signal LEDR : std_logic_vector(9 downto 0) := (others => '0');
    signal LEDG : std_logic_vector(7 downto 0) := (others => '0');
    signal HEX3 : std_logic_vector(6 downto 0) := (others => '0');
    signal HEX2 : std_logic_vector(6 downto 0) := (others => '0');
    signal HEX1 : std_logic_vector(6 downto 0) := (others => '0');
    signal HEX0 : std_logic_vector(6 downto 0) := (others => '0');
    signal CLOCK_50_B6A : std_logic := '0';
    signal UART_RX : std_logic := '1';
    signal UART_TX : std_logic := '1';
    
    constant CLK_PERIOD : time := 20 ns;
    
begin
    
    uut : entity work.toplevel
    port map(
        CPU_RESET_n => CPU_RESET_n,
        SW   => SW,
        KEY  => KEY,
        LEDR => LEDR,
        LEDG => LEDG,
        HEX3 => HEX3,
        HEX2 => HEX2,
        HEX1 => HEX1,
        HEX0 => HEX0,
        CLOCK_50_B6A => CLOCK_50_B6A,
        UART_RX => UART_RX,
        UART_TX => UART_TX
    );
    
    -- Manual clock setting
    SW(9) <= '0';

    -- Reset pulse on KEY(3)
    CPU_RESET_n <= '0', '1' after 100 ns;
    
    -- Clock cycling on KEY(0)
    process
    begin
        KEY(0) <= '1';
        wait for CLK_PERIOD / 2;
        KEY(0) <= '0';
        wait for CLK_PERIOD / 2;
    end process;

    -- Master clock generation
    process
    begin
        CLOCK_50_B6A <= '0';
        wait for CLK_PERIOD / 2;
        CLOCK_50_B6A <= '1';
        wait for CLK_PERIOD / 2;
    end process;

    
end behavioral;