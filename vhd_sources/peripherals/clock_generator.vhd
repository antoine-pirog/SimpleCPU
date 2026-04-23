library ieee ;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity clock_generator is
    generic (
        CLOCK_FREQ : integer := 50000000 -- Frequency of input clock (Hz)
    );
	port (
        auto_clk_in       : in std_logic;
        manual_clk_in     : in std_logic;
        rst               : in std_logic;
        mode_fast_slowN   : in std_logic;
        mode_ultra_slow   : in std_logic;
        mode_auto_manualN : in std_logic;
        clk_out           : out std_logic
	);
end clock_generator;

architecture behavioral of clock_generator is
    constant CPU_CLOCK_FAST           : integer := 1000; -- Output clock frequency (Hz)
    constant CPU_CLOCK_NORMAL         : integer := 10;   -- Output clock frequency (Hz)
    constant CPU_CLOCK_SLOW           : integer := 1;    -- Output clock frequency (Hz)
    constant CPU_CLOCK_DIVIDER_FAST   : integer := CLOCK_FREQ / (2 * CPU_CLOCK_FAST); 
    constant CPU_CLOCK_DIVIDER_NORMAL : integer := CLOCK_FREQ / (2 * CPU_CLOCK_NORMAL); 
    constant CPU_CLOCK_DIVIDER_SLOW   : integer := CLOCK_FREQ / (2 * CPU_CLOCK_SLOW); 
    signal clk_auto           : std_logic := '0';
    signal clk_manual         : std_logic := '0';
    signal clk_counter        : unsigned(31 downto 0) := (others => '0');
    signal clk_divider_factor : unsigned(31 downto 0) := to_unsigned(2500000, 32);
begin
    process(auto_clk_in, rst)
    begin
        -- 1 MHz  : 25
        -- 1 kHz  : 25000
        -- 100 Hz : 250000
        -- 10 Hz  : 2500000
        -- 1 Hz   : 25000000
        if rst = '1' then
            clk_counter <= (others => '0');
            clk_auto <= '0';
        elsif rising_edge(auto_clk_in) then
            if clk_counter >= clk_divider_factor then
                clk_counter <= (others => '0');
                clk_auto <= not clk_auto;
            else
                clk_counter <= clk_counter + 1;
            end if;
        end if;
    end process;

    clk_divider_factor <= to_unsigned(CPU_CLOCK_DIVIDER_SLOW  , 32) when (mode_ultra_slow = '0') else 
                          to_unsigned(CPU_CLOCK_DIVIDER_NORMAL, 32) when (mode_fast_slowN = '0') else 
                          to_unsigned(CPU_CLOCK_DIVIDER_FAST  , 32);

    clk_out <= manual_clk_in when mode_auto_manualN = '0' else clk_auto;
end behavioral;