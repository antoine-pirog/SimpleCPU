library ieee ;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity register_generic is
    generic( 
        data_width : integer := 8
    ); 
    port (
        Din  : in  std_logic_vector(data_width-1 downto 0);
        Dout : out std_logic_vector(data_width-1 downto 0);
        clk : in std_logic;
        rst : in std_logic
    );
end register_generic;

architecture behavioral of register_generic is
signal memory : std_logic_vector(data_width-1 downto 0);

begin
    process(clk, rst) 
    begin 
        if rst = '1' then
            memory <= (others => '0');
        elsif (clk'event and clk = '1') then 
            memory <= Din;
        end if; 
    end process; 

    Dout <= memory;
end architecture;