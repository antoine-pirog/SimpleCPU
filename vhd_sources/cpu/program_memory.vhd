library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity program_memory is
    port (
        -- Normal operation
        addr : in  std_logic_vector(7 downto 0);
        data_out : out std_logic_vector(7 downto 0);
        -- Reprogramming operation
        write_enable : in  std_logic := '0';
        data_in : in std_logic_vector(7 downto 0);
        clk : in std_logic := '0'
    );
end program_memory;

architecture behavioral of program_memory is
    -- ROM definition
    type rom_array is array (0 to 255) of std_logic_vector(7 downto 0);
    signal rom_data : rom_array := (
            x"0E",
            x"01",
            x"08",
            x"04",
            x"04",
            x"0E",
            x"02",
            x"08",
            x"04",
            x"04",
            x"0E",
            x"04",
            x"08",
            x"04",
            x"04",
            x"0E",
            x"08",
            x"08",
            x"04",
            x"04",
            x"0E",
            x"10",
            x"08",
            x"04",
            x"04",
            x"0E",
            x"20",
            x"08",
            x"04",
            x"04",
            x"0E",
            x"40",
            x"08",
            x"04",
            x"04",
            x"0E",
            x"80",
            x"08",
            x"04",
            x"04",
            x"0B",
            others => x"00"
    );
    -- Reprogramming signals
    signal write_address : integer range 0 to 255 := 0;

begin
    -- Normal operation
    data_out <= rom_data(to_integer(unsigned(addr)));

    -- Reprogramming operation
    process(clk)
    begin
        if rising_edge(clk) then
            if write_enable = '0' then
                write_address <= 0;
            else
                if write_address <= 255 then
                    rom_data(write_address) <= data_in;
                    write_address <= write_address + 1;
                end if;
            end if;
        end if;
    end process;

end architecture;