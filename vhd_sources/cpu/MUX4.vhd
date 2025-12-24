library ieee ;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity MUX4 is
    generic( 
        data_width : integer := 8
    ); 
    port (
        X0 : in  std_logic_vector(data_width-1 downto 0);
        X1 : in  std_logic_vector(data_width-1 downto 0);
        X2 : in  std_logic_vector(data_width-1 downto 0);
        X3 : in  std_logic_vector(data_width-1 downto 0);
        Y  : out std_logic_vector(data_width-1 downto 0);
        Sel : in std_logic_vector(1 downto 0)
    );
end MUX4;

architecture behavioral of MUX4 is

begin

    with Sel select
        Y <= X0 when "00",
             X1 when "01",
             X2 when "10",
             X3 when "11",
             (others => '0') when others;
    
    
end architecture;