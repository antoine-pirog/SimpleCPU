import re

# ----------------------------
# Define instruction functions
# ----------------------------

def NOP(args):
    opcode = 0b00100
    return f"0x{opcode:02X}"

def INPUT(args):
    opcode = 0b00101
    return f"0x{opcode:02X}"

def OUTPUT(args):
    opcode = 0b01000
    return f"0x{opcode:02X}"

def JMP(args):
    opcode = 0b01011
    addr = int_value(args[0])
    return f"0x{opcode:02X} 0x{addr:02X}"

def LDA(args):
    opcode = 0b01110
    value = int_value(args[0])
    return f"0x{opcode:02X} 0x{value:02X}"

def INC(args):
    opcode = 0b10011
    reg = args[0].strip()
    assert reg=="A", f"Register {reg} unsupported for operator INC (INC A only)"
    return f"0x{opcode:02X}"

def MOV(args):
    opcode = 0b10110
    reg1 = args[0].strip()
    reg2 = args[1].strip()
    assert (reg1=="B") and (reg2=="A"), f"Registers {reg1},{reg2} unsupported for operator MOV (MOV B,A only)"
    return f"0x{opcode:02X}"

def ADD(args):
    opcode = 0b11001
    reg1 = args[0].strip()
    reg2 = args[1].strip()
    assert (reg1=="A") and (reg2=="B"), f"Registers {reg1},{reg2} unsupported for operator ADD (ADD A,B only)"
    return f"0x{opcode:02X}"

def HLT(args):
    opcode = 0b11111
    return f"0x{opcode:02X}"

# Map instruction regex patterns to functions
instructions = {
    r"NOP"           : NOP,
    r"INPUT"         : INPUT,
    r"OUTPUT"        : OUTPUT,
    r"LDA (.+)"      : LDA,
    r"JMP (.+)"      : JMP,
    r"INC (.+)"      : INC,
    r"MOV (.+),(.+)" : MOV,
    r"ADD (.+),(.+)" : ADD,
    r"HLT"           : HLT,
}

def int_value(text):
    # Determine integer value from string with base prefix
    if text.startswith("0x"):
        return int(text, base=16)
    elif text.startswith("0b"):
        return int(text, base=2)
    elif text.startswith("0d"):
        return int(text, base=10)
    else:
        return int(text)

def parse_asm(code):
    # Parse assembly code into machine code
    machine_code = ""
    for line in code.split("\n"):
        if "#" in line:
            idx = line.find("#", 1)
            line = line[:idx]
        line = line.strip()
        for ins in instructions:
            match = re.compile(ins).match(line)
            if match:
                machine_code += instructions[ins](match.groups()) + " "
    return machine_code

if __name__ == "__main__":
    import argparse
    parser = argparse.ArgumentParser(description="Assemble assembly code to machine code")
    parser.add_argument("-i", "--input_file", help="Path to the assembly code file")
    parser.add_argument("-o", "--output_file", help="Path to the output machine code file", default="machine_code.txt")
    parser.add_argument("-f", "--format", help="Output format (raw/bin/hex)", default="raw")
    args = parser.parse_args()
    
    with open(args.input_file, "r") as f:
        asm_code = f.read()
    
    machine_code_hex = parse_asm(asm_code) # Machine code as string of hex (0x--) values separated by spaces
    machine_code_raw = bytes(int(x,16) for x in machine_code_hex.split())

    assert len(machine_code_raw) <= 256, "Assembled machine code exceeds 256 bytes"

    while len(machine_code_raw) < 256:
        machine_code_raw += bytes([0x00])  # Pad with 0x00 to reach 256 bytes

    # Pretty print machine code
    print("Assembled Machine Code:")
    for i in range(0, len(machine_code_raw), 8):
        chunk = machine_code_raw[i:i+8]
        addr = i
        print(f"@0x{addr:02X} : " + " ".join(f"0x{byte:02X}" for byte in chunk))

    # Write output in the requested format
    if args.format == "raw":
        with open(args.output_file, "wb") as f:
            f.write(machine_code_raw)
    elif args.format == "bin":
        with open(args.output_file, "w") as f:
            for byte in machine_code_raw:
                f.write(f"0b{byte:08b}\n")
    elif args.format == "hex":
        with open(args.output_file, "w") as f:
            for byte in machine_code_raw:
                f.write(f"0x{byte:02X}\n")
    elif args.format == "mif":
        with open(args.output_file, "w") as f:
            f.write("WIDTH=8;\n")
            f.write("DEPTH=256;\n")
            f.write("\n")
            f.write("ADDRESS_RADIX=HEX;\n")
            f.write("DATA_RADIX=HEX;\n")
            f.write("\n")
            f.write("CONTENT BEGIN\n")
            for i,byte in enumerate(machine_code_raw):
                f.write(f"  {i:02X} : {byte:02X};\n")
            f.write("END;")
