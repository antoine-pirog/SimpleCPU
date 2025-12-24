library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart_tx is
    generic (
        CLOCK_FREQ : integer := 50000000; -- 50 MHz
        BAUD_RATE  : integer := 115200
    );
    port (
        clk      : in  std_logic;
        reset_n  : in  std_logic;
        tx_start : in  std_logic;
        tx_data  : in  std_logic_vector(7 downto 0);
        tx       : out std_logic;
        tx_busy  : out std_logic
    );
end entity;

architecture rtl of uart_tx is

    constant BAUD_TICK_COUNT : integer := CLOCK_FREQ / BAUD_RATE;

    type state_type is (IDLE, START, DATA, STOP);
    signal state    : state_type := IDLE;

    signal baud_cnt : integer range 0 to BAUD_TICK_COUNT := 0;
    signal bit_cnt  : integer range 0 to 7 := 0;
    signal data_reg : std_logic_vector(7 downto 0) := (others => '0');

begin

    process(clk)
    begin
        if rising_edge(clk) then
            if reset_n = '0' then
                state    <= IDLE;
                tx       <= '1'; -- idle line
                tx_busy  <= '0';
                baud_cnt <= 0;
                bit_cnt  <= 0;

            else
                case state is

                    when IDLE =>
                        tx       <= '1';
                        tx_busy  <= '0';

                        if tx_start = '1' then
                            data_reg <= tx_data;
                            baud_cnt <= BAUD_TICK_COUNT - 1;
                            state    <= START;
                            tx_busy  <= '1';
                        end if;

                    when START =>
                        tx <= '0'; -- start bit
                        if baud_cnt = 0 then
                            baud_cnt <= BAUD_TICK_COUNT - 1;
                            bit_cnt  <= 0;
                            state    <= DATA;
                        else
                            baud_cnt <= baud_cnt - 1;
                        end if;

                    when DATA =>
                        tx <= data_reg(bit_cnt);
                        if baud_cnt = 0 then
                            baud_cnt <= BAUD_TICK_COUNT - 1;
                            if bit_cnt = 7 then
                                state <= STOP;
                            else
                                bit_cnt <= bit_cnt + 1;
                            end if;
                        else
                            baud_cnt <= baud_cnt - 1;
                        end if;

                    when STOP =>
                        tx <= '1'; -- stop bit
                        if baud_cnt = 0 then
                            state <= IDLE;
                        else
                            baud_cnt <= baud_cnt - 1;
                        end if;

                end case;
            end if;
        end if;
    end process;

end architecture;