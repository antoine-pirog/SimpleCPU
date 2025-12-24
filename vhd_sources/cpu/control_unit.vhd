library ieee ;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.state_pkg.all;

entity control_unit is
    port (
        instruction        : in  std_logic_vector(7 downto 0);
        write_lines        : out std_logic_vector(4 downto 0);
        alu_func           : out std_logic_vector(2 downto 0);
        B_mux_sel          : out std_logic_vector(1 downto 0);
        control_unit_state : out control_unit_state_type;
        clk         : in  std_logic;
        rst         : in  std_logic
    );
end control_unit;

architecture behavioral of control_unit is

    signal microbyte            : std_logic_vector(4 downto 0) := (others => '0');
    signal microprogram_counter : std_logic_vector(4 downto 0) := (others => '0');
    signal next_microbyte       : std_logic_vector(4 downto 0) := (others => '0');

    signal microinstruction_from_memory : std_logic_vector(15 downto 0) := (others => '0');
    signal microinstruction             : std_logic_vector(15 downto 0) := (others => '0');
	 
	signal jmpc : std_logic := '0';
    signal notclk : std_logic := '0';

begin

    microbyte <= instruction(4 downto 0) when (jmpc = '1') else next_microbyte;
    
    next_microbyte <= microinstruction(15 downto 11);
    jmpc           <= microinstruction(10);
    alu_func       <= microinstruction( 9 downto  7);
    write_lines    <= microinstruction( 6 downto  2);
    B_mux_sel      <= microinstruction( 1 downto  0);

    notclk <= not clk;
    
    -- Describe control unit state with legible states
    process(microprogram_counter, rst)
    begin
        if rst = '1' then
            control_unit_state <= reset;
        else
            case microprogram_counter is
                when "00000" =>
                    control_unit_state <= fetch;
                when "00001" =>
                    control_unit_state <= increment_pc;
                when "00010" =>
                    control_unit_state <= store_pc;
                when "00011" =>
                    control_unit_state <= execute;
                when "00100" =>
                    control_unit_state <= nop;
                when "00101" =>
                    control_unit_state <= ld_input;
                when "01000" =>
                    control_unit_state <= print_output;
                when "01011" =>
                    control_unit_state <= jmp;
                when "01110" =>
                    control_unit_state <= lda;
                when "10011" =>
                    control_unit_state <= inc;
                when "10110" =>
                    control_unit_state <= mov;
                when "11001" =>
                    control_unit_state <= add;
                when "11100" =>
                    control_unit_state <= sub;
                when "11111" =>
                    control_unit_state <= halt;
                when others =>
                    control_unit_state <= other;
            end case;
        end if;
    end process;
    
    -- Route microprogram counter and microinstruction registers
    microprogram_memory : entity work.microprogram_memory
    port map(
        addr => microprogram_counter,
        data => microinstruction_from_memory);

    -- Microprogram counter register
    microprogram_counter_register : entity work.register_generic
    generic map(
        data_width => 5
    )
    port map(
        Din => microbyte,
        Dout => microprogram_counter,
        clk => clk,
        rst => rst
    );

    -- Microinstruction register
    microinstruction_register : entity work.register_generic
    generic map(
        data_width => 16
    )
    port map(
        Din => microinstruction_from_memory,
        Dout => microinstruction,
        clk => notclk,
        rst => rst
    );
    
end architecture;