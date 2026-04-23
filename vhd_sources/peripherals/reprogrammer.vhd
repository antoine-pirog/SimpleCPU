library ieee ;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.state_pkg.all;

entity reprogrammer is
	port (
        clk : in std_logic;
        rst_n : in std_logic;
        uart_rx_data       : in std_logic_vector(7 downto 0);
        uart_rx_data_ready : in std_logic;
        uart_tx_data       : out std_logic_vector(7 downto 0);
        uart_tx_start      : out std_logic;
        reprogram_enable  : out std_logic;
        reprogram_data    : out std_logic_vector(7 downto 0);
        reprogram_clk     : out std_logic;
        reprogram_address : out std_logic_vector(7 downto 0)
	);
end reprogrammer;

architecture behavioral of reprogrammer is
    signal reprogram_counter : integer range 0 to 256 := 256; -- 256 means idle mode ; [0-255] means reprogramming at corresponding address
    signal reprogram_state       : reprogrammer_stage := idle;
begin
-- Reprogramming state machine
    --   Send 'R' (0x52) via UART to start reprogramming (CPU is automatically put in reset state)
    --   Send binary file (256 bytes to fill shared memory)
    --   When 256 bytes are sent, CPU automatically resumes normal operation
    process(clk, rst_n)
    begin
        if rst_n = '0' then
            reprogram_state <= reset;
            reprogram_counter <= 0;
        else
            if rising_edge(clk) then
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

    process(clk, rst_n)
    begin
        if reprogram_state = reset then
            reprogram_enable <= '0';
            reprogram_data <= (others => '0');
            reprogram_clk <= '0';
        else
            if rising_edge(clk) then
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

end behavioral;
