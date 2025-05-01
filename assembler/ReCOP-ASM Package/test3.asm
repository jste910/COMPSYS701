start NOOP ;starting the program
        LDR R0 #0
		LDR R1 #1
        LDR R3 #2989
        LDR R5 #4077
		LDR R4 #4096 ; bits before looping
		
count	SUBV R4 R4 #1
        NOOP;
		PRESENT R4 start;if R4=0 go to start
		SSVOP R4
		NOOP
        DATACALL R4; Nonblocking call
		PRESENT R0 trig;
		NOOP
		LDR R2 #65535 ;max register size, 16 bits

time	SUBV R2 R2 #1
		PRESENT R2 count ;if R2=0 go to count
		JMP time

trig    SSVOP R3
        DATACALL R3 #0; should be a blocking call
        SSVOP R5
        



ENDPROG
