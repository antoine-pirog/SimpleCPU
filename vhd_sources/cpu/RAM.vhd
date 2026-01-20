library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity RAM is
    port (
        -- Read operation
        data_out : out std_logic_vector(7 downto 0);
        read_addr : in  std_logic_vector(7 downto 0);
        -- Write operation
        data_in : in std_logic_vector(7 downto 0);
        write_addr : in  std_logic_vector(7 downto 0);
        write_enable : in  std_logic := '0';
        -- Common
        clk  : in  std_logic
    );
end RAM;

architecture behavioral of RAM is
    -- RAM definition
    type ram_array is array (0 to 255) of std_logic_vector(7 downto 0);
    constant ram_init : ram_array := (x"0E", x"01", x"08", x"04", x"04", x"0E", x"02", x"08", x"04", x"04", x"0E", x"04", x"08", x"04", x"04", x"0E", x"08", x"08", x"04", x"04", x"0E", x"10", x"08", x"04", x"04", x"0E", x"20", x"08", x"04", x"04", x"0E", x"40", x"08", x"04", x"04", x"0E", x"80", x"08", x"04", x"04", x"0B", others => x"00");
    signal ram_data : ram_array := ram_init;
    attribute ram_init_file : string;
    attribute ram_init_file of ram_data : signal is "vhd_sources/cpu/default_program.mif";

begin
    process(clk)
    begin
        if (clk'event and clk = '1') then 
            -- Read operation
            data_out <= ram_data(to_integer(unsigned(read_addr)));

            -- Write operation
            if (write_enable = '1') then
                ram_data(to_integer(unsigned(write_addr))) <= data_in;
            end if;
        end if;
    end process;
end architecture;