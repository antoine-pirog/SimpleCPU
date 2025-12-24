LDA 0xF1 # 1. Charger 241 dans le registre A
INC A    # 2. incrémenter le registre A
MOV B,A  # 3. Copier A dans B
LDA 0x0D # 4. Charger 13 dans le registre A
ADD A,B  # 5. Additionner A et B
OUTPUT   # 4. Afficher A
HLT      # 6. Terminer le programme