library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart_rx is
    generic (
        CLOCK_FREQ : integer := 50000000; -- 50 MHz
        BAUD_RATE  : integer := 115200
    );
    port (
        clk      : in  std_logic;
        reset_n  : in  std_logic;
        rx       : in  std_logic;
        rx_data  : out std_logic_vector(7 downto 0);
        rx_valid : out std_logic
    );
end entity;

architecture behavioral of uart_rx is

    constant BAUD_TICK_COUNT : integer := CLOCK_FREQ / BAUD_RATE;
    constant HALF_BAUD_TICK  : integer := BAUD_TICK_COUNT / 2;

    type state_type is (idle, start, data, stop);
    signal state       : state_type := idle;

    signal baud_cnt    : integer range 0 to BAUD_TICK_COUNT := 0;
    signal bit_cnt     : integer range 0 to 7 := 0;
    signal data_reg    : std_logic_vector(7 downto 0) := (others => '0');

begin

    process(clk, reset_n)
    begin
        if rising_edge(clk) then
            if reset_n = '0' then
                state    <= idle;
                baud_cnt <= 0;
                bit_cnt  <= 0;
                rx_valid <= '0';
            else
                rx_valid <= '0';

                case state is

                    when idle =>
                        if rx = '0' then -- start bit detected
                            baud_cnt <= HALF_BAUD_TICK;
                            state    <= start;
                        end if;

                    when start =>
                        if baud_cnt = 0 then
                            baud_cnt <= BAUD_TICK_COUNT - 1;
                            bit_cnt  <= 0;
                            state    <= data;
                        else
                            baud_cnt <= baud_cnt - 1;
                        end if;

                    when data =>
                        if baud_cnt = 0 then
                            data_reg(bit_cnt) <= rx;
                            baud_cnt <= BAUD_TICK_COUNT - 1;

                            if bit_cnt = 7 then
                                state <= stop;
                            else
                                bit_cnt <= bit_cnt + 1;
                            end if;
                        else
                            baud_cnt <= baud_cnt - 1;
                        end if;

                    when stop =>
                        if baud_cnt = 0 then
                            rx_data  <= data_reg;
                            rx_valid <= '1';
                            state    <= idle;
                        else
                            baud_cnt <= baud_cnt - 1;
                        end if;

                end case;
            end if;
        end if;
    end process;

end architecture;