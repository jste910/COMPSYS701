start NOOP ;starting the program
		LDR R1 #10;
        MAX R1 #13
        NOOP
        LDR R2 #10
        LDR R3 #11
        STR R2 #3
        STR R3 R1
    STR R1 $12
        NOOP
        NOOP
        LDR R7 R2
        LDR R8 $11
        LDR R9 $12
        NOOP
ENDPROGe