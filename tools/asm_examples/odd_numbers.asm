LDA 2    # 1. Charger 2 dans le registre A
MOV B,A  # 2. Copier A dans B
LDA 1    # 3. Charger 1 dans le registre A
OUTPUT   # 4. Afficher A
ADD A,B  # 5. Additionner A et B
JMP 5    # 6. Sauter à 5.