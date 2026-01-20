library ieee ;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.state_pkg.all;

entity toplevel is
port (
    SW          : in  std_logic_vector(9 downto 0);
    KEY         : in  std_logic_vector(3 downto 0);
    CPU_RESET_n : in  std_logic;
    LEDR : out std_logic_vector(9 downto 0);
    LEDG : out std_logic_vector(7 downto 0);
    HEX3 : out std_logic_vector(6 downto 0);
    HEX2 : out std_logic_vector(6 downto 0);
    HEX1 : out std_logic_vector(6 downto 0);
    HEX0 : out std_logic_vector(6 downto 0);
    CLOCK_50_B6A : in  std_logic;
    UART_RX : in  std_logic;
    UART_TX : out std_logic
);
end toplevel;

-- INTERFACES DESCRIPTION
-- CPU_RESET : Active low reset input
-- SW(9) : Manual/Automatic clock select (0 = automatic, 1 = manual)
-- SW(8) : Automatic clock speed select (0 = slow, 1 = fast)
-- SW(7 downto 0) : Manual input to CPU (when selected)
-- KEY(0) : Manual clock input (when selected)
-- KEY(3) : Ultra slow clock
-- LEDR(9) : Indicates automatic clock state
-- LEDR(7 downto 0) : Program counter state
-- LEDG(7 downto 0) : Output register state
-- UART : Reprogramming interface
--   1. Send 'R' (0x52) via UART to start reprogramming
--   2. Send 256 bytes of program data
--   3. After last byte, '/' (0x2F) is sent back to acknowledge end of reprogramming

architecture behavioral of toplevel is
    -- Architecture parameters
    constant CLOCK_FREQ : integer := 50000000;
    constant UART_BAUD_RATE : integer := 115200;
    constant CPU_CLOCK_FAST   : integer := 1000; 
    constant CPU_CLOCK_NORMAL : integer := 10;   
    constant CPU_CLOCK_SLOW   : integer := 1;   
    constant CPU_CLOCK_DIVIDER_FAST   : integer := CLOCK_FREQ / (2 * CPU_CLOCK_FAST);
    constant CPU_CLOCK_DIVIDER_NORMAL : integer := CLOCK_FREQ / (2 * CPU_CLOCK_NORMAL); 
    constant CPU_CLOCK_DIVIDER_SLOW   : integer := CLOCK_FREQ / (2 * CPU_CLOCK_SLOW);

    -- Main signals
    signal clk : std_logic := '0';
    signal rst : std_logic := '0';

    -- Clock generation signals
    signal clk_auto           : std_logic := '0';
    signal clk_manual         : std_logic := '0';
    signal clk_counter        : unsigned(31 downto 0) := (others => '0');
    signal clk_divider_factor : unsigned(31 downto 0) := to_unsigned(2500000, 32);

    -- I/O signals
    signal manual_input         : std_logic_vector(7 downto 0) := (others => '0');
    signal current_instruction  : std_logic_vector(7 downto 0) := (others => '0');
    signal out_register_bus     : std_logic_vector(7 downto 0) := (others => '0');
    signal pc_register_bus      : std_logic_vector(7 downto 0) := (others => '0');
    signal control_unit_state   : control_unit_state_type := other;

    -- Reprogramming signals
    signal uart_rx_data       : std_logic_vector(7 downto 0) := (others => '0');
    signal uart_rx_data_ready : std_logic := '0';
    signal uart_tx_data       : std_logic_vector(7 downto 0) := (others => '0');
    signal uart_tx_start      : std_logic := '0';
    signal reprogram_counter : integer range 0 to 256 := 256; -- 256 means idle mode ; [0-255] means reprogramming at corresponding address
    signal reprogram_state       : reprogrammer_stage := idle;
    signal reprogram_enable      : std_logic := '0';
    signal reprogram_clk         : std_logic := '0';
    signal reprogram_data        : std_logic_vector(7 downto 0) := (others => '0');
    signal reprogram_address     : std_logic_vector(7 downto 0) := (others => '0');


begin
    --------------------------------------------------
    -- CLOCK GENERATION
    --------------------------------------------------

    process(CLOCK_50_B6A, rst)
    begin
        -- 1 MHz  : 25
        -- 1 kHz  : 25000
        -- 100 Hz : 250000
        -- 10 Hz  : 2500000
        -- 1 Hz   : 25000000
        if rst = '1' then
            clk_counter <= (others => '0');
            clk_auto <= '0';
        elsif rising_edge(CLOCK_50_B6A) then
            if clk_counter >= clk_divider_factor then
                clk_counter <= (others => '0');
                clk_auto <= not clk_auto;
            else
                clk_counter <= clk_counter + 1;
            end if;
        end if;
    end process;

    clk_divider_factor <= to_unsigned(CPU_CLOCK_DIVIDER_SLOW, 32) when(KEY(3) = '0') else to_unsigned(CPU_CLOCK_DIVIDER_NORMAL, 32) when SW(8) = '0' else to_unsigned(CPU_CLOCK_DIVIDER_FAST, 32);

    LEDR(9) <= clk_auto;

    --------------------------------------------------
    -- I/O routing
    --------------------------------------------------

    rst <= not(CPU_RESET_n) or reprogram_enable;
    clk <= not(KEY(0)) when SW(9) = '0' else clk_auto;
    manual_input <= SW(7 downto 0);
    LEDG <= out_register_bus;
    LEDR(7 downto 0) <= pc_register_bus when reprogram_enable = '0' else reprogram_address;

    --------------------------------------------------
    -- HEX DISPLAY
    --------------------------------------------------

    hex_display : entity work.hex_display
    port map(
        control_unit_state => control_unit_state,
        instruction        => current_instruction,
        HEX3 => HEX3,
        HEX2 => HEX2,
        HEX1 => HEX1,
        HEX0 => HEX0
    );

    --------------------------------------------------
    -- CPU INSTANCE
    --------------------------------------------------

    cpu_instance : entity work.cpu
    port map(
        -- Baese cpu inputs/outputs
        clk => clk,
        rst => rst,
        manual_input => manual_input,
        print_output => out_register_bus,
        -- Reprogramming interface
        reprogram_enable  => reprogram_enable,
        reprogram_address => reprogram_address,
        reprogram_data_in => reprogram_data,
        reprogram_clk     => reprogram_clk,
        -- CPU monitoring outputs
        monitor_control_unit_state => control_unit_state,
        monitor_current_instruction => current_instruction,
        monitor_pc_register_bus => pc_register_bus
    );

    --------------------------------------------------
    -- UART INSTANCE
    --------------------------------------------------

    uart_rx_handler : entity work.uart_rx
    generic map(
        CLOCK_FREQ => CLOCK_FREQ,
        BAUD_RATE  => UART_BAUD_RATE
    )
    port map(
        clk => CLOCK_50_B6A,
        reset_n => CPU_RESET_n,
        rx  => UART_RX,
        rx_data  => uart_rx_data,
        rx_valid => uart_rx_data_ready
    );

    uart_tx_handler : entity work.uart_tx
    generic map(
        CLOCK_FREQ => CLOCK_FREQ,
        BAUD_RATE  => UART_BAUD_RATE
    )
    port map(
        clk      => CLOCK_50_B6A,
        reset_n  => CPU_RESET_n,
        tx_start => uart_tx_start,
        tx_data  => uart_tx_data,
        tx       => UART_TX,
        tx_busy  => open
    );

    -- Reprogramming state machine
    --   Send 'R' (0x52) via UART to start reprogramming (CPU is automatically put in reset state)
    --   Send binary file (256 bytes to fill shared memory)
    --   When 256 bytes are sent, CPU automatically resumes normal operation
    process(CLOCK_50_B6A, CPU_RESET_n)
    begin
        if CPU_RESET_n = '0' then
            reprogram_state <= reset;
            reprogram_counter <= 0;
        else
            if rising_edge(CLOCK_50_B6A) then
                case reprogram_state is
                    when idle => 
                        reprogram_counter <= 0;
                        if uart_rx_data_ready = '1' and uart_rx_data = x"52" then 
                            reprogram_state <= initiate;
                        else 
                            reprogram_state <= idle;
                        end if;
                    when initiate =>
                        reprogram_counter <= 0;
                        if uart_rx_data_ready = '1' then
                            reprogram_state <= reprogram;
                        else
                            reprogram_state <= initiate;
                        end if;
                    when reprogram =>
                        if uart_rx_data_ready = '1' then
                            reprogram_counter <= reprogram_counter + 1;
                        end if;
                        if reprogram_counter = 255 then
                            reprogram_state <= idle;
                        end if;
                    when others => 
                        reprogram_counter <= 0;
                        reprogram_state <= idle;
                end case;
            end if;
        end if;
    end process;

    process(CLOCK_50_B6A, CPU_RESET_n)
    begin
        if reprogram_state = reset then
            reprogram_enable <= '0';
            reprogram_data <= (others => '0');
            reprogram_clk <= '0';
        else
            if rising_edge(CLOCK_50_B6A) then
                case reprogram_state is
                    when idle =>
                        if uart_rx_data_ready = '1' and uart_rx_data = x"52" then 
                            uart_tx_data  <= x"52"; -- Echo 'R' to acknowledge reprogram request received
                            uart_tx_start <= '1';
                        else
                            uart_tx_start <= '0';
                        end if;
                        reprogram_enable <= '0';
                        reprogram_data <= (others => '0');
                        reprogram_clk <= '0';
                    when initiate => 
                        uart_tx_start <= '0';
                        reprogram_enable <= '1';
                        reprogram_data <= (others => '0');
                        reprogram_clk <= '0';
                    when reprogram =>
                        if uart_rx_data_ready = '1' then
                            reprogram_clk <= '1';
                            if reprogram_counter = 255 then
                                uart_tx_data <= x"2F"; -- Send '/' to indicate end of reprogramming
                                uart_tx_start <= '1';
                            else
                                uart_tx_data  <= x"2D"; -- Echo '-' to acknowledge byte received
                                uart_tx_start <= '1';
                            end if;
                        else
                            reprogram_clk <= '0';
                            uart_tx_start <= '0';
                        end if;
                        reprogram_enable <= '1';
                        reprogram_data <= uart_rx_data;
                    when others =>
                        reprogram_enable <= '0';
                        reprogram_data <= (others => '0');
                        reprogram_clk <= '0';
                        uart_tx_data <= (others => '0');
                        uart_tx_start <= '0';
                end case;
            end if;
        end if;
    end process;

    reprogram_address <= std_logic_vector(to_unsigned(reprogram_counter, reprogram_address'length));

    LEDR(8) <= reprogram_enable;

end architecture;