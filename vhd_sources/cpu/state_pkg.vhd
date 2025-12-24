library ieee;
use ieee.std_logic_1164.all;

package state_pkg is
    type control_unit_state_type is (
        reset,
        fetch,
        increment_pc,
        store_pc,
        execute,
        nop,
        ld_input,
        print_output,
        jmp,
        lda,
        inc,
        mov,
        add,
        sub,
        halt,
        other
    );
end package state_pkg;