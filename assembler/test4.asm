start
    NOOP

loop1_in
    LDR R0 #1
    LDR R1 #1

loop1
    SSVOP R1
    DATACALL R1 #0
    PRESENT R0 loop2_in
    JMP loop1

loop2_in
    LDR R0 #1
    LDR R1 #2

loop2
    SSVOP R1
    DATACALL R1 #0
    PRESENT R0 loop1_in
    JMP loop2

ENDPROG
