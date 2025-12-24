import re

def translate_microprogram(microprogram_path):
    table = []
    with open(microprogram_path, "r") as f:
        lines = f.readlines()
        for i,l in enumerate(lines):
            if i == 0:
                # Header
                continue
                
            # Handle comments
            if "#" in l:
                l = l[:l.index("#")]
                
            # Handle empty lines
            l = l.strip()
            if not l:
                continue
                
            # Retrieve fields
            match = re.compile(r"(.*?)\|(.*?)\|(.*?)\|(.*?)\|(.*?)\|(.*)").match(l)
            addr      = match.group(1)
            addr_next = match.group(2)
            JMPC      = match.group(3)
            ALU       = match.group(4)
            WL        = match.group(5)
            B         = match.group(6)
            
            # Handle empties
            if not addr_next.strip():
                addr_next = "00000"
            if not ALU.strip():
                ALU = "000"
            if not JMPC.strip() :
                JMPC = "0"
            if not WL.strip():
                WL = "00000"
            if not B.strip():
                B = "00"
            
            table.append([addr, addr_next, JMPC, ALU, WL, B])

    # Handle next_addr == +1
    for i,l in enumerate(table):
        if l[1].strip() == "+1":
            table[i][1] = table[i+1][0]

    return table

def bin2hex(nibble):
    table = {
        "0000" : "0",
        "0001" : "1",
        "0010" : "2",
        "0011" : "3",
        "0100" : "4",
        "0101" : "5",
        "0110" : "6",
        "0111" : "7",
        "1000" : "8",
        "1001" : "9",
        "1010" : "A",
        "1011" : "B",
        "1100" : "C",
        "1101" : "D",
        "1110" : "E",
        "1111" : "F",
    }
    return table[nibble]
        
if __name__ == "__main__":
    import argparse
    parser = argparse.ArgumentParser(description="Compile microprogram to microcode")
    parser.add_argument("-i", "--input_file", help="Path to the microprogram file")
    parser.add_argument("-o", "--output_file", help="Path to the output microcode file", default="microcode.mem")
    parser.add_argument("-f", "--format", help="Output format (bin/hex/vhdl/mem)", default="vhdl")
    args = parser.parse_args()
    
    microprogram_path = args.input_file
    table = translate_microprogram(microprogram_path)

    # Pretty-print microcode table
    print("Microcode Table:")
    for i,l in enumerate(table):
        print(f"@0x{i:>04X} : " + " | ".join(l[1:]))

    if args.format == "bin":
        with open (args.output_file, "w") as f:
            for l in table:
                f.write("0b" + "".join(l[1:]) + "\n")
    elif args.format == "hex":
        with open(args.output_file, "w") as f:
            for l in table:
                bits = "".join(l[1:])
                f.write(f"0x{bin2hex(bits[0:4])}{bin2hex(bits[4:8])}{bin2hex(bits[8:12])}{bin2hex(bits[12:16])}\n")
    elif args.format == "vhdl":
        with open(args.output_file, "w") as f:
            for i,l in enumerate(table):
                tmp = []
                for x in l:
                    if len(x) > 1:
                        tmp.append(f'"{x}"')
                    else:
                        tmp.append(f"'{x}'")
                f.write(f"{' & '.join(tmp[1:])}, -- @0x{i:>04X}\n")
    elif args.format == "mem":
        with open(args.output_file, "w") as f:
            for l in table:
                bits = "".join(l[1:])
                f.write(f"{int(bits,2)}\n")