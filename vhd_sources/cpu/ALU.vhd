library ieee ;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ALU is
    generic( 
        data_width : integer := 8
    ); 
    port (
        A  : in  std_logic_vector(data_width-1 downto 0);
        B  : in  std_logic_vector(data_width-1 downto 0);
        Y  : out std_logic_vector(data_width-1 downto 0);
        Func : in std_logic_vector(2 downto 0)
    );
end ALU;

architecture behavioral of ALU is

signal sum_operand_A : std_logic_vector(data_width-1 downto 0) := (others => '0');
signal sum_operand_B : std_logic_vector(data_width-1 downto 0) := (others => '0');
signal sum_result    : std_logic_vector(data_width-1 downto 0) := (others => '0');

begin

    with Func select
        Y <= A        when "000",
             B        when "001",
            (A and B) when "010",
            (A or B)  when "011",
            sum_result when "100",
            sum_result when "101",
            sum_result when "110",
            sum_result when "111",
            (others => '0') when others;
    
    with Func select
        sum_operand_A <= A        when "100",
                         B        when "101",
                         A        when "110",
                         A        when "111",
                         std_logic_vector(to_unsigned(0, data_width)) when others;

    with Func select
        sum_operand_B <= std_logic_vector(to_unsigned(1, data_width)) when "100",
                         std_logic_vector(to_unsigned(1, data_width)) when "101",
                         B                                            when "110",
                         std_logic_vector(unsigned(not B) + 1)        when "111",
                         std_logic_vector(to_unsigned(0, data_width)) when others;

    sum_result <= std_logic_vector(unsigned(sum_operand_A) + unsigned(sum_operand_B));
    
end architecture;