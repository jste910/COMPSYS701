start NOOP ;starting the program
		LDR R1 #1
		LDR R8 #1
		LDR R4 #16 ;16 bits before looping
		
count	SUBV R4 R4 #1
		NOOP;
		PRESENT R4 start ;if R4=0 go to start
		ADD R1 R1 R1 ;”double” the number
		ADD R8 R8 #1
		SSOP R1
		SSVOP R8
		NOOP
		NOOP
		NOOP
		LDR R2 #65535 ;max register size, 16 bits
time		SUBV R2 R2 #1
		PRESENT R2 count ;if R2=0 go to count
		JMP time
ENDPROG
END