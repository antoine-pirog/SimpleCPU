INPUT    # Load manual input to reg A
MOV B,A  # Copy A to B
LDA 0    # Load 0 to reg A
ADD A,B  # Add A and B
OUTPUT   # Output the result
JMP 3    # Repeat from step 3