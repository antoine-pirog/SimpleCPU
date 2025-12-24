library ieee ;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.state_pkg.all;

entity hex_display is
    port (
        control_unit_state : in  control_unit_state_type;
        instruction        : in  std_logic_vector(7 downto 0);
        HEX3 : out std_logic_vector(6 downto 0);
        HEX2 : out std_logic_vector(6 downto 0);
        HEX1 : out std_logic_vector(6 downto 0);
        HEX0 : out std_logic_vector(6 downto 0)
    );
end hex_display;

architecture behavioral of hex_display is

constant char_cap_A : std_logic_vector(6 downto 0) := "0001000";
constant char_cap_B : std_logic_vector(6 downto 0) := "0000011";
constant char_cap_C : std_logic_vector(6 downto 0) := "1000110";
constant char_cap_D : std_logic_vector(6 downto 0) := "0100001";
constant char_cap_E : std_logic_vector(6 downto 0) := "0000110";
constant char_cap_F : std_logic_vector(6 downto 0) := "0001110";
constant char_cap_G : std_logic_vector(6 downto 0) := "1000010";
constant char_cap_H : std_logic_vector(6 downto 0) := "0001001";
constant char_cap_I : std_logic_vector(6 downto 0) := "1111001";
constant char_cap_J : std_logic_vector(6 downto 0) := "1110001";
--K
constant char_cap_L : std_logic_vector(6 downto 0) := "1000111";
constant char_cap_M : std_logic_vector(6 downto 0) := "1001000";
constant char_cap_N : std_logic_vector(6 downto 0) := "1001000";
constant char_cap_O : std_logic_vector(6 downto 0) := "1000000";
constant char_cap_P : std_logic_vector(6 downto 0) := "0001100";
constant char_cap_Q : std_logic_vector(6 downto 0) := "0011000";
constant char_cap_R : std_logic_vector(6 downto 0) := "0101111";
constant char_cap_S : std_logic_vector(6 downto 0) := "0010010";
constant char_cap_T : std_logic_vector(6 downto 0) := "0000111";
constant char_cap_U : std_logic_vector(6 downto 0) := "1000001";
constant char_cap_V : std_logic_vector(6 downto 0) := "1000001";
--W
--X
constant char_cap_Y : std_logic_vector(6 downto 0) := "0010001";
--Z

constant char_a : std_logic_vector(6 downto 0) := "0001000";
constant char_b : std_logic_vector(6 downto 0) := "0000011";
constant char_c : std_logic_vector(6 downto 0) := "0100111";
constant char_d : std_logic_vector(6 downto 0) := "0100001";
constant char_e : std_logic_vector(6 downto 0) := "0000110";
constant char_f : std_logic_vector(6 downto 0) := "0001110";
constant char_g : std_logic_vector(6 downto 0) := "1000010";
constant char_h : std_logic_vector(6 downto 0) := "0001011";
constant char_i : std_logic_vector(6 downto 0) := "1111011";
constant char_j : std_logic_vector(6 downto 0) := "1110001";
--k
constant char_l : std_logic_vector(6 downto 0) := "1000111";
constant char_m : std_logic_vector(6 downto 0) := "0101011";
constant char_n : std_logic_vector(6 downto 0) := "0101011";
constant char_o : std_logic_vector(6 downto 0) := "0100011";
constant char_p : std_logic_vector(6 downto 0) := "0001100";
constant char_q : std_logic_vector(6 downto 0) := "0011000";
constant char_r : std_logic_vector(6 downto 0) := "0101111";
constant char_s : std_logic_vector(6 downto 0) := "0010010";
constant char_t : std_logic_vector(6 downto 0) := "0000111";
constant char_u : std_logic_vector(6 downto 0) := "1100011";
constant char_v : std_logic_vector(6 downto 0) := "1100011";
--w
--x
constant char_y : std_logic_vector(6 downto 0) := "0010001";
--z

constant char_0 : std_logic_vector(6 downto 0) := "1000000";
constant char_1 : std_logic_vector(6 downto 0) := "1111001";
constant char_2 : std_logic_vector(6 downto 0) := "0100100";
constant char_3 : std_logic_vector(6 downto 0) := "0110000";
constant char_4 : std_logic_vector(6 downto 0) := "0011001";
constant char_5 : std_logic_vector(6 downto 0) := "0010010";
constant char_6 : std_logic_vector(6 downto 0) := "0000010";
constant char_7 : std_logic_vector(6 downto 0) := "1111000";
constant char_8 : std_logic_vector(6 downto 0) := "0000000";
constant char_9 : std_logic_vector(6 downto 0) := "0001000";

signal instruction_high_nibble : std_logic_vector(3 downto 0);
signal instruction_low_nibble  : std_logic_vector(3 downto 0);
signal instruction_high_nibble_hex : std_logic_vector(6 downto 0);
signal instruction_low_nibble_hex  : std_logic_vector(6 downto 0);

begin

    instruction_high_nibble <= instruction(7 downto 4);
    instruction_low_nibble  <= instruction(3 downto 0);

    process(instruction)
    begin
        -- Bin to hex for instructions
        case instruction_high_nibble is
            when x"0" =>
                instruction_high_nibble_hex <= char_0;
            when x"1" =>
                instruction_high_nibble_hex <= char_1;
            when x"2" =>
                instruction_high_nibble_hex <= char_2;
            when x"3" =>
                instruction_high_nibble_hex <= char_3;
            when x"4" =>
                instruction_high_nibble_hex <= char_4;
            when x"5" =>
                instruction_high_nibble_hex <= char_5;
            when x"6" =>
                instruction_high_nibble_hex <= char_6;
            when x"7" =>
                instruction_high_nibble_hex <= char_7;
            when x"8" =>
                instruction_high_nibble_hex <= char_8;
            when x"9" =>
                instruction_high_nibble_hex <= char_9;
            when x"A" =>
                instruction_high_nibble_hex <= char_cap_A;
            when x"B" =>
                instruction_high_nibble_hex <= char_cap_B;
            when x"C" =>
                instruction_high_nibble_hex <= char_cap_C;
            when x"D" =>
                instruction_high_nibble_hex <= char_cap_D;
            when x"E" =>
                instruction_high_nibble_hex <= char_cap_E;
            when x"F" =>
                instruction_high_nibble_hex <= char_cap_F;
            when others =>
                instruction_high_nibble_hex <= "0111111";
        end case;

        case instruction_low_nibble is
            when x"0" =>
                instruction_low_nibble_hex <= char_0;
            when x"1" =>
                instruction_low_nibble_hex <= char_1;
            when x"2" =>
                instruction_low_nibble_hex <= char_2;
            when x"3" =>
                instruction_low_nibble_hex <= char_3;
            when x"4" =>
                instruction_low_nibble_hex <= char_4;
            when x"5" =>
                instruction_low_nibble_hex <= char_5;
            when x"6" =>
                instruction_low_nibble_hex <= char_6;
            when x"7" =>
                instruction_low_nibble_hex <= char_7;
            when x"8" =>
                instruction_low_nibble_hex <= char_8;
            when x"9" =>
                instruction_low_nibble_hex <= char_9;
            when x"A" =>
                instruction_low_nibble_hex <= char_cap_A;
            when x"B" =>
                instruction_low_nibble_hex <= char_cap_B;
            when x"C" =>
                instruction_low_nibble_hex <= char_cap_C;
            when x"D" =>
                instruction_low_nibble_hex <= char_cap_D;
            when x"E" =>
                instruction_low_nibble_hex <= char_cap_E;
            when x"F" =>
                instruction_low_nibble_hex <= char_cap_F;
            when others =>
                instruction_low_nibble_hex <= "0111111";
        end case;

    end process;

    process (control_unit_state)
	 begin
        case control_unit_state is 
            when reset =>
                HEX3 <= char_r;
                HEX2 <= char_s;
                HEX1 <= char_t;
                HEX0 <= (others => '1'); -- blank
            when fetch =>
                -- Display "Fetc"
                HEX3 <= char_cap_F;
                HEX2 <= char_E;
                HEX1 <= char_t;
                HEX0 <= char_c;
            when increment_pc =>
                -- Display "Incr"
                HEX3 <= char_cap_I;
                HEX2 <= char_n;
                HEX1 <= char_c;
                HEX0 <= char_r;
            when store_pc =>
                -- Display "Stor"
                HEX3 <= char_cap_S;
                HEX2 <= char_t;
                HEX1 <= char_o;
                HEX0 <= char_r;
            when execute =>
                -- Display "Run"
                HEX3 <= char_cap_R;
                HEX2 <= char_u;
                HEX1 <= char_n;
                HEX0 <= (others => '1'); -- blank
            when halt =>
                -- Display "Hlt"
                HEX3 <= char_cap_H;
                HEX2 <= char_l;
                HEX1 <= char_t;
                HEX0 <= (others => '1'); -- blank
            when ld_input =>
                -- Display "Ldin"
                HEX3 <= char_cap_L;
                HEX2 <= char_d;
                HEX1 <= char_i;
                HEX0 <= char_n;
            when print_output =>
                -- Display "Prt"
                HEX3 <= char_cap_P;
                HEX2 <= char_r;
                HEX1 <= char_t;
                HEX0 <= (others => '1'); -- blank
            when jmp =>
                -- Display "Jmp"
                HEX3 <= char_cap_J;
                HEX2 <= char_m;
                HEX1 <= char_p;
                HEX0 <= (others => '1'); -- blank
            when lda =>
                -- Display "Lda"
                HEX3 <= char_cap_L;
                HEX2 <= char_d;
                HEX1 <= char_a;
                HEX0 <= (others => '1'); -- blank
            when inc =>
                -- Display "Inc"
                HEX3 <= char_cap_I;
                HEX2 <= char_n;
                HEX1 <= char_c;
                HEX0 <= (others => '1'); -- blank
            when mov =>
                -- Display "Mov"
                HEX3 <= char_cap_M;
                HEX2 <= char_o;
                HEX1 <= char_v;
                HEX0 <= (others => '1'); -- blank
            when add =>
                -- Display "Add"
                HEX3 <= char_cap_A;
                HEX2 <= char_d;
                HEX1 <= char_d;
                HEX0 <= (others => '1'); -- blank
            when sub =>
                -- Display "Sub"
                HEX3 <= char_cap_S;
                HEX2 <= char_u;
                HEX1 <= char_b;
                HEX0 <= (others => '1'); -- blank
            when nop =>
                -- Display "nop"
                HEX3 <= char_n;
                HEX2 <= char_o;
                HEX1 <= char_p;
                HEX0 <= (others => '1'); -- blank
            when other =>
                -- Display ----
                HEX3 <= "0111111"; -- blank
                HEX2 <= instruction_high_nibble_hex;
                HEX1 <= instruction_low_nibble_hex;
                HEX0 <= "0111111"; -- blank
            when others =>
                HEX3 <= (others => '1');
                HEX2 <= (others => '1');
                HEX1 <= (others => '1');
                HEX0 <= (others => '1');
            end case;
    end process;

end architecture;