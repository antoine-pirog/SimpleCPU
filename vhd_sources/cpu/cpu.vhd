library ieee ;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.state_pkg.all;

entity cpu is
port (
    -- Base cpu inputs/outputs
    clk       : in  std_logic;
    rst       : in  std_logic;
    manual_input : in  std_logic_vector(7 downto 0);
    print_output : out std_logic_vector(7 downto 0);
    -- Reprogramming interface
    reprogram_enable  : in std_logic;
    reprogram_address : in std_logic_vector(7 downto 0);
    reprogram_data_in : in std_logic_vector(7 downto 0);
    reprogram_clk     : in std_logic;
    -- Monitoring outputs
    monitor_control_unit_state  : out control_unit_state_type;
    monitor_current_instruction : out std_logic_vector(7 downto 0);
    monitor_pc_register_bus     : out std_logic_vector(7 downto 0)
);
end cpu;


architecture behavioral of cpu is

signal pc_register_bus      : std_logic_vector(7 downto 0) := (others => '0');
signal instr_register_bus   : std_logic_vector(7 downto 0) := (others => '0');
signal out_register_bus     : std_logic_vector(7 downto 0) := (others => '0');
signal B_register_bus       : std_logic_vector(7 downto 0) := (others => '0');
signal B_bus     : std_logic_vector(7 downto 0) := (others => '0');
signal A_bus     : std_logic_vector(7 downto 0) := (others => '0');

signal data_bus        : std_logic_vector(7 downto 0) := (others => '0');
signal instruction_bus : std_logic_vector(7 downto 0) := (others => '0');

signal write_lines : std_logic_vector(4 downto 0) := (others => '0');
signal wl_pc    : std_logic := '0';
signal wl_instr : std_logic := '0';
signal wl_out   : std_logic := '0';
signal wl_b     : std_logic := '0';
signal wl_a     : std_logic := '0';

signal alu_func  : std_logic_vector(2 downto 0) := (others => '0');
signal B_mux_sel : std_logic_vector(1 downto 0) := (others => '0');

signal memory_addr : std_logic_vector(7 downto 0) := (others => '0');
signal memory_clk : std_logic := '0';

signal control_unit_state : control_unit_state_type := other;

begin
    --------------------------------------------------
    -- Routing
    --------------------------------------------------

    print_output <= out_register_bus;

    monitor_current_instruction <= instr_register_bus;
    monitor_pc_register_bus <= pc_register_bus;
    monitor_control_unit_state <= control_unit_state;

    --------------------------------------------------
    -- Write lines
    --------------------------------------------------

    wl_pc      <= write_lines(0);
    wl_instr   <= write_lines(1);
    wl_out     <= write_lines(2);
    wl_b       <= write_lines(3);
    wl_a       <= write_lines(4);

    --------------------------------------------------
    -- REGISTERS 
    --------------------------------------------------

    programcounter_register : entity work.register_generic 
    generic map(
        data_width => 8
    )
    port map(
        Din => data_bus,
        Dout => pc_register_bus,
        clk => wl_pc,
        rst => rst
    );

    instruction_register : entity work.register_generic 
    generic map(
        data_width => 8
    )
    port map(
        Din => instruction_bus,
        Dout => instr_register_bus,
        clk => wl_instr,
        rst => rst
    );

    out_register : entity work.register_generic 
    generic map(
        data_width => 8
    )
    port map(
        Din => data_bus,
        Dout => out_register_bus,
        clk => wl_out,
        rst => rst
    );

    B_register : entity work.register_generic 
    generic map(
        data_width => 8
    )
    port map(
        Din => data_bus,
        Dout => B_register_bus,
        clk => wl_b,
        rst => rst
    );

    A_register : entity work.register_generic 
    generic map(
        data_width => 8
    )
    port map(
        Din => data_bus,
        Dout => A_bus,
        clk => wl_a,
        rst => rst
    );

    --------------------------------------------------
    -- ALU 
    --------------------------------------------------
    ALU : entity work.ALU 
    generic map(
        data_width => 8
    )
    port map(
        A  => A_bus,
        B  => B_bus,
        Y  => data_bus,
        Func => alu_func
    );

    B_bus_mux : entity work.MUX4
    port map(
        X0 => B_register_bus,
        X1 => instr_register_bus,
        X2 => pc_register_bus,
        X3 => manual_input,
        Y  => B_bus,
		Sel => B_mux_sel
    );

    --------------------------------------------------
    -- SHARED MEMORY
    --------------------------------------------------

    memory_clk <= clk when reprogram_enable = '0' else reprogram_clk;

    shared_memory : entity work.RAM
    port map(
        clk => memory_clk,
        read_addr => pc_register_bus,
        write_addr => reprogram_address,
        data_out => instruction_bus,
        write_enable => reprogram_enable,
        data_in => reprogram_data_in
    );

    --------------------------------------------------
    -- CONTROL UNIT
    --------------------------------------------------
    control_unit : entity work.control_unit
    port map(
        instruction => instr_register_bus,
        write_lines => write_lines,
        alu_func    => alu_func,
        B_mux_sel   => B_mux_sel,
        control_unit_state => control_unit_state,
        clk         => clk,
        rst         => rst
    );

end architecture;